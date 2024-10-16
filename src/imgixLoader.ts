import { ImageLoader } from "next/image";

export const imgixLoader: ImageLoader = ({ src, width, quality }) => {
  // const baseUrl = process.env.IMGIX_URL // can't be used in the browser
  const baseUrl = `/images/${src}`;

  const params = new URLSearchParams();
  params.set("auto", "format");
  params.set("fit", "max");
  params.set("w", width.toString());
  params.set("q", (quality || 50).toString());

  return `${baseUrl}?${params.toString()}`;
};
