/** @type {import('next').NextConfig} */
const nextConfig = {
  output: "standalone",
  rewrites: async () => {
    return [
      {
        source: "/images/:path*",
        destination:
          process.env.NODE_ENV !== "production"
            ? `https://${process.env.IMGIX_URL}/:path*`
            : `https://$IMGIX_URL/:path*`, // use placeholder for production build, will get replaced by entrypoint.sh script
      },
    ];
  },
};

export default nextConfig;
