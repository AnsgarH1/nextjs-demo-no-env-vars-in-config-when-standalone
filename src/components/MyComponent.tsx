"use client";

import { imgixLoader } from "@/util/imgixLoader";
import styles from "./MyComponent.module.css";
import Image from "next/image";

export const MyComponent = () => {
  return (
    <div className={styles.imageContainer}>
      <Image
        src="/puppy.jpg"
        alt="a cute puppy"
        width={5184}
        height={3456}
        loader={imgixLoader}
        
        style={{
          width: "100%",
          height: "auto",
          objectFit: "cover",
        }}
      />
    </div>
  );
};
