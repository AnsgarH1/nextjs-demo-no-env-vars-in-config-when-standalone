/** @type {import('next').NextConfig} */
const nextConfig = {
  output: "standalone",
  rewrites: async () => {
    return [
      {
        source: "/images/:path*",
        destination: `https://${process.env.IMGIX_URL}/:path*`,
      },
    ];
  },
};

export default nextConfig;
