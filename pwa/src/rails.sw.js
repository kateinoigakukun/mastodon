// NOTICE: This file is based on Vladimir Dementyev's work.
// https://github.com/palkan/turbo-music-drive/blob/spike/wasmify/.wasm/pwa-app/sw.js

import { instantiate } from "../dist/component/ruby"
import * as preview2Shim from "@bytecodealliance/preview2-shim"
import { RubyVM } from "@ruby/wasm-wasi";
import * as tar from "tar-stream"
import setCookieParser from "set-cookie-parser"

// Inject XHR shim for Emscripten in PGlite
import XMLHttpRequestShim from "xhr-shim"
globalThis.XMLHttpRequest = XMLHttpRequestShim
// Load PGlite from CDN to make import.meta.url-based .wasm file loading work
import { PGlite } from "https://cdn.jsdelivr.net/npm/@electric-sql/pglite/dist/index.js";


class BootProgress {
    constructor() {
        this.listeners = new Set();
        this.currentStep = "Initializing..."
        this.currentValue = 0
    }
    addListener(listener) {
        this.listeners.add(listener);
    }
    removeListener(listener) {
        this.listeners.delete(listener);
    }
    notifyListeners() {
        for (const listener of this.listeners) {
            listener.postMessage({
                type: "progress",
                step: this.currentStep,
                value: this.currentValue,
            });
        }
    }
    updateStep(step) {
        this.currentStep = step;
        this.currentValue = 0;
        this.notifyListeners();
    }
    updateProgress(value) {
        this.currentValue = value;
        this.notifyListeners();
    }
}

function teeDownloadProgress(response, progress) {
    let loaded = 0
    return new Response(new ReadableStream({
        async start(controller) {
            const reader = response.body.getReader();
            while (true) {
                const { done, value } = await reader.read();
                if (done) break;
                loaded += value.byteLength;
                progress(loaded);
                controller.enqueue(value);
            }
            controller.close();
        },
    }));
}

async function _fetchFileData(progress) {
    progress.updateStep("Fetching fs.tar.gz")
    const rawTarballResponse = await fetch("/fs.tar.gz")
    const tarballResponse = teeDownloadProgress(rawTarballResponse, (downloaded) => {
        const percentage = (downloaded / rawTarballResponse.headers.get("content-length")) * 100
        progress.updateProgress(percentage)
    })
    const fsMetadata = await fetch("/fs.meta.json").then((res) => res.json())
    const totalNumberOfFiles = fsMetadata["number_of_files"]

    const gzipDecompress = new DecompressionStream("gzip")
    const tarStream = tarballResponse.body.pipeThrough(gzipDecompress)
    const tarExtract = tar.extract()
    const buffer = await new Response(tarStream).arrayBuffer()
    tarExtract.write(Buffer.from(buffer))
    tarExtract.end()

    const mkdir_p = (path) => {
        const parts = path.split("/")
        let current = root
        for (let i = 0; i < parts.length; i++) {
            if (parts[i] === "" || parts[i] === ".") {
                continue
            }
            if (!current.dir[parts[i]]) {
                current.dir[parts[i]] = { dir: {} }
            }
            current = current.dir[parts[i]]
        }
        return current
    }

    const root = { dir: {} }
    const dataWorks = []
    let numberOfExtractedFiles = 0

    progress.updateStep("Extracting fs.tar.gz")

    for await (const entry of tarExtract) {
        const path = entry.header.name.split("/")
        if (entry.header.type === "file") {
            const parent = mkdir_p(path.slice(0, -1).join("/"))
            const file = { source: null }
            parent.dir[path[path.length - 1]] = file
            const dataWork = new Promise((resolve, reject) => {
                const chunks = []
                entry.on("data", (chunk) => {
                    chunks.push(chunk)
                })
                entry.on("end", () => {
                    file.source = new Uint8Array(Buffer.concat(chunks))
                    resolve()
                })
                entry.on("error", (err) => {
                    reject(err)
                })
            })
            dataWorks.push((async () => {
                await dataWork
                numberOfExtractedFiles += 1
                progress.updateProgress((numberOfExtractedFiles / totalNumberOfFiles) * 100)
            })())
        } else if (entry.header.type === "directory") {
            numberOfExtractedFiles += 1
            mkdir_p(entry.header.name)
        }
    }

    await Promise.all(dataWorks)

    mkdir_p("/home/katei/ghq/github.com/ruby/ruby.wasm")

    return root
}
let fetchFileDataTask = null
async function fetchFileData(progress) {
    if (fetchFileDataTask) {
        return fetchFileDataTask
    }
    fetchFileDataTask = _fetchFileData(progress)
    return fetchFileDataTask
}

async function instantiateRuby(args, progress) {
    const vmOptions = { args: args }
    const vm = await RubyVM._instantiate(async (jsRuntime) => {
        const { cli, clocks, filesystem, io, random, sockets } = preview2Shim;
        const root = await fetchFileData(progress)

        progress.updateStep("Initializing Ruby VM")

        filesystem._setFileData(root)
        filesystem._setCwd("/rails")
        cli._setArgs(args)
        cli._setEnv({
            BUNDLE_ONLY: "web",
            BUNDLE_PATH: "/bundle",
            BUNDLE_GEMFILE: "/rails/Gemfile",
            HOME: "/home/me",
            RAILS_ENV: "production",
            RAILS_WEB: "1",
        })
        const component = await instantiate((path) => {
            return WebAssembly.compileStreaming(fetch("/component/" + path))
        }, {
            "ruby:js/js-runtime": jsRuntime,
            "wasi:cli/environment": cli.environment,
            "wasi:cli/exit": cli.exit,
            "wasi:cli/stderr": cli.stderr,
            "wasi:cli/stdin": cli.stdin,
            "wasi:cli/stdout": cli.stdout,
            "wasi:cli/terminal-input": cli.terminalInput,
            "wasi:cli/terminal-output": cli.terminalOutput,
            "wasi:cli/terminal-stderr": cli.terminalStderr,
            "wasi:cli/terminal-stdin": cli.terminalStdin,
            "wasi:cli/terminal-stdout": cli.terminalStdout,
            "wasi:clocks/monotonic-clock": clocks.monotonicClock,
            "wasi:clocks/wall-clock": clocks.wallClock,
            "wasi:filesystem/preopens": filesystem.preopens,
            "wasi:filesystem/types": filesystem.types,
            "wasi:io/error": io.error,
            "wasi:io/poll": io.poll,
            "wasi:io/streams": io.streams,
            "wasi:random/random": random.random,
            "wasi:sockets/tcp": sockets.tcp,
        })
        return component.rubyRuntime;
    }, vmOptions)
    progress.updateProgress(100)
    return vm
}

async function initPGlite(progress) {
    /**
     * @type {import("@electric-sql/pglite").PGlite}
     */
    const pglite = new PGlite()
    progress.updateStep("Initializing PGlite")
    const dumpFile = await fetch("/mastodon_development.sql").then((res) => res.text())
    await pglite.exec(dumpFile)
    await pglite.waitReady
    return pglite
}

async function _initRails(progress) {
    self.PGLite4Rails = await initPGlite(progress)

    const vm = await instantiateRuby(["ruby", "-e", "_=0"], progress)
    self.RailsVM = vm // for debugging
    vm.eval(`
# FIXME: Not sure why Bundler does not add these paths
$LOAD_PATH.unshift "/bundle/ruby/3.4.0+0/bundler/gems/ruby.wasm-0ca30636702e/packages/gems/js/lib"
$LOAD_PATH.unshift "/bundle/ruby/3.4.0+0/bundler/gems/extensions/wasm32-wasi/3.4.0+0-static/ruby.wasm-0ca30636702e-js"
$LOAD_PATH.unshift "/bundle/ruby/3.4.0+0/extensions/wasm32-wasi/3.4.0+0-static/bigdecimal-3.1.7"
`)
    progress.updateStep("Bootstrapping Rails")
    const script = await fetch("/rails.main.rb").then((res) => res.text())
    await vm.evalAsync(script)
    progress.updateProgress(100)
    return vm;
}

let initRailsTask = null
async function initRails(progress) {
    if (initRailsTask) {
        return initRailsTask
    }
    initRailsTask = _initRails(progress)
    return initRailsTask
}

const bootProgress = new BootProgress();

self.railsRestart = async () => {
    initRailsTask = null
    await initRails(bootProgress)
}

self.railsReloadPGlite = async () => {
    RailsVM.evalAsync(`Kernel.eval(JS.global.fetch("/pglite.rb").await.text.await.to_s, TOPLEVEL_BINDING, "/pglite.rb")`)
}

self.addEventListener('install', function (event) {
    event.waitUntil((async () => {
        const clients = await self.clients.matchAll({ includeUncontrolled: true });
        for (const client of clients) {
            bootProgress.addListener(client);
        }

        const consoleOutput = (message) => {
            for (const client of clients) {
                client.postMessage({ type: "console", message: message });
            }
        }
        const outs = [
            preview2Shim.cli.stdout.getStdout(),
            preview2Shim.cli.stderr.getStderr(),
        ]
        const originalHandlers = outs.map((out) => out.handler)
        for (const out of outs) {
            const originalWrite = out.handler.write
            out.handler = {
                ...out.handler,
                write(contents) {
                    consoleOutput(new TextDecoder().decode(contents));
                    originalWrite.call(out.handler, contents);
                },
            }
        }
        await initRails(bootProgress)

        for (const out of outs) {
            out.handler = originalHandlers.shift()
        }
    })());
});


self.addEventListener('activate', () => {
    console.log('activate');
});

class RailsRequestQueue {
    constructor(respond) {
        this._respond = respond;
        this.isProcessing = false;
        this.queue = [];
    }

    async respond(request) {
        if (this.isProcessing) {
            return new Promise((resolve) => {
                this.queue.push({ request, resolve });
            })
        }
        const response = await this.process(request);
        queueMicrotask(() => this.tick());
        return response;
    }

    async process(request) {
        this.isProcessing = true;
        let response;
        try {
            response = await this._respond(request);
        } catch (e) {
            console.error(e);
            response = new Response(`Application Error: ${e.message}`, {
                status: 500,
            });
        } finally {
            this.isProcessing = false;
        }
        return response;
    }

    async tick() {
        if (this.queue.length === 0) {
            return;
        }
        const { request, resolve } = this.queue.shift();
        const response = await this.process(request);
        resolve(response);
        queueMicrotask(() => this.tick());
    }
}


const requestQueue = new RailsRequestQueue(_respondWithRails);

self.addEventListener('fetch', function (event) {
    const bootResources = [
        "/boot.js", "/boot.html", "/rails.sw.js"
    ]
    if (bootResources.find((r) => event.request.url.endsWith(r))) {
        console.log('[rails-web] Fetching boot files from network:', event.request.url);
        event.respondWith(fetch(event.request.url));
        return;
    }
    const url = new URL(event.request.url);
    if (url.pathname.startsWith("/packs/")) {
        console.log('[rails-web] Fetching pack file from network:', event.request.url);
        const publicPath = url.pathname.replace("/packs/", "/rails/public/packs/")
        const newURL = new URL(publicPath, location.origin)
        return event.respondWith(fetch(newURL));
    }
    {
        const publicTopLevelPaths = [
            "500.html",
            "assets",
            "avatars",
            "badge.png",
            "embed.js",
            "emoji",
            "favicon.ico",
            "headers",
            "ocr",
            "oops.gif",
            "oops.png",
            "packs",
            "robots.txt",
            "sounds",
            "web-push-icon_expand.png",
            "web-push-icon_favourite.png",
            "web-push-icon_reblog.png"
        ]
        if (publicTopLevelPaths.find((p) => url.pathname.startsWith(`/${p}`))) {
            console.log('[rails-web] Fetching public file from network:', event.request.url);
            const newURL = new URL(`/rails/public${url.pathname}`, location.origin)
            return event.respondWith(fetch(newURL));
        }
    }
    event.respondWith(requestQueue.respond(event.request));
})

self.addEventListener('message', async function (event) {
    console.log('[rails-web] Service Worker received message:', event.data);
    switch (event.data.type) {
        case "init-rails": {
            bootProgress.addListener(event.source);
            await initRails(bootProgress)
            bootProgress.removeListener(event.source);
            break;
        }
        default: {
            console.log('[rails-web] Unknown message type:', event.data.type);
        }
    }
})

async function _respondWithRails(request) {
    try {
        const response = await respondWithRails(request);
        return response
    } catch (e) {
        console.error(e);
    }
}

const respondWithRails = async (request) => {
    const vm = await initRails(bootProgress);

    const railsURL = request.url.replace("https://", "http://");

    try {
        const cookies = await cookieStore.getAll();
        const railsCookie = cookies.map((c) => `${c.name}=${c.value}`).join("; ");

        const command = `$rack_handler`;
        const proc = vm.eval(command)
        const res = await proc.callAsync("call", vm.wrap(railsURL), vm.wrap(request), vm.wrap(railsCookie));
        let { status, headers, body } = res;

        const cookie = headers["Set-Cookie"];

        if (cookie) {
            const cookies = setCookieParser.parse(cookie, { decodeValues: false });
            for (const c of cookies) {
                console.log("[rails-web]", "Setting Cookie", c);
                await cookieStore.set({
                    name: c.name,
                    value: c.value,
                    domain: c.domain,
                    path: c.path,
                    expires: c.expires,
                    sameSite: c.sameSite.toLowerCase(),
                });
            }
            delete headers["Set-Cookie"];
        }

        // Convert image into a blob
        if (headers["Content-Type"] == "image/png") {
            console.log("[rails-web]", "Converting image into blob");

            body = await fetch(`data:image/png;base64,${body}`).then((res) =>
                res.blob()
            );
        }

        if (headers["Location"]) {
            headers["Location"] = headers["Location"].replace("http://localhost/", "/")
        }

        return new Response(body, { headers, status });
    } catch (e) {
        console.error(e);
        return new Response(`Application Error: ${e.message}`, {
            status: 500,
        });
    }
};
