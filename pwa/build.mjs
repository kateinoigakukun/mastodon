import esbuild from "esbuild";
import { polyfillNode } from "esbuild-plugin-polyfill-node";

const buildOptions = {
    entryPoints: ["src/boot.js", "src/rails.sw.js"],
    bundle: true,
    outdir: "dist",
    sourcemap: true,
    logLevel: "debug",
    format: "esm",
    plugins: [polyfillNode()],
}

if (process.argv.includes("--watch")) {
    const build = await esbuild.context(buildOptions)

    await build.serve({
        servedir: "dist",
        onRequest: async (args) => {
            console.log(`${args.method} ${args.path} ${args.status} ${args.timeInMS}ms`)
        }
    })
} else {
    await esbuild.build(buildOptions)
}
