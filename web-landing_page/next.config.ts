import type { NextConfig } from "next";

const nextConfig: NextConfig = {
  // Produce a fully static HTML/CSS/JS export in `out/`.
  // This lets Firebase Hosting serve the landing page at the domain root
  // without a Node.js runtime, which is required for SEO and fast first paint.
  output: "export",

  // Static export has no Next.js image optimization server, so serve images as-is.
  images: {
    unoptimized: true,
  },

  // Emit `/features/index.html` instead of `/features.html`.
  // Directory-style URLs are cleaner on static hosting and align with the
  // Firebase Hosting catch-all rewrite strategy (landing at `/`, Flutter at `/app`).
  trailingSlash: true,
};

export default nextConfig;
