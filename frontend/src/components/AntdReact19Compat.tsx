"use client";

import { useEffect } from "react";
import { unstableSetRender } from "antd";
import { createRoot } from "react-dom/client";

let isConfigured = false;

export function AntdReact19Compat() {
  useEffect(() => {
    if (isConfigured) {
      return;
    }

    unstableSetRender((node, container) => {
      const root = createRoot(container);
      root.render(node);

      return async () => {
        root.unmount();
      };
    });

    isConfigured = true;
  }, []);

  return null;
}
