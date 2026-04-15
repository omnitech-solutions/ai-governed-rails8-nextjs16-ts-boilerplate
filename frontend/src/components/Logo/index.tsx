"use client";

interface LogoProps {
  size?: "sm" | "md" | "lg";
  showText?: boolean;
}

interface LogoMarkProps {
  size: "sm" | "md" | "lg";
  noBackground?: boolean;
}

export function LogoMark({ size, noBackground = false }: LogoMarkProps) {
  const dimensions = {
    sm: { container: 36, icon: 22 },
    md: { container: 44, icon: 26 },
    lg: { container: 56, icon: 32 },
  };

  const { container, icon } = dimensions[size];

  if (noBackground) {
    return (
      <svg
        width={icon}
        height={icon}
        viewBox="0 0 24 24"
        fill="none"
        xmlns="http://www.w3.org/2000/svg"
      >
        <defs>
          <linearGradient
            id={`logo-icon-gradient-${size}`}
            x1="0"
            y1="0"
            x2="24"
            y2="24"
            gradientUnits="userSpaceOnUse"
          >
            <stop offset="0%" stopColor="#667eea" />
            <stop offset="25%" stopColor="#764ba2" />
            <stop offset="50%" stopColor="#f093fb" />
            <stop offset="75%" stopColor="#f5576c" />
            <stop offset="100%" stopColor="#4facfe" />
          </linearGradient>
        </defs>
        <path
          d="M12 2L2 7L12 12L22 7L12 2Z"
          fill={`url(#logo-icon-gradient-${size})`}
        />
        <path
          d="M2 12L12 17L22 12"
          stroke={`url(#logo-icon-gradient-${size})`}
          strokeWidth="2"
          strokeLinecap="round"
          strokeLinejoin="round"
        />
        <path
          d="M2 17L12 22L22 17"
          stroke={`url(#logo-icon-gradient-${size})`}
          strokeWidth="2"
          strokeLinecap="round"
          strokeLinejoin="round"
          opacity="0.8"
        />
      </svg>
    );
  }

  return (
    <div
      className="logo__mark"
      style={{
        width: container,
        height: container,
        display: "flex",
        alignItems: "center",
        justifyContent: "center",
        borderRadius: 12,
        background:
          "linear-gradient(135deg, #667eea 0%, #764ba2 25%, #f093fb 50%, #f5576c 75%, #4facfe 100%)",
        boxShadow:
          "0 6px 20px rgba(102, 126, 234, 0.4), inset 0 1px 0 rgba(255,255,255,0.2)",
        position: "relative",
        overflow: "hidden",
        flexShrink: 0,
      }}
    >
      <div
        style={{
          position: "absolute",
          inset: 0,
          background:
            "linear-gradient(135deg, rgba(255,255,255,0.2) 0%, transparent 50%)",
          borderRadius: 12,
        }}
      />
      <svg
        width={icon}
        height={icon}
        viewBox="0 0 24 24"
        fill="none"
        xmlns="http://www.w3.org/2000/svg"
        style={{ position: "relative", zIndex: 1 }}
      >
        <path d="M12 2L2 7L12 12L22 7L12 2Z" fill="white" fillOpacity="0.95" />
        <path
          d="M2 12L12 17L22 12"
          stroke="white"
          strokeWidth="2"
          strokeLinecap="round"
          strokeLinejoin="round"
          fillOpacity="0.9"
        />
        <path
          d="M2 17L12 22L22 17"
          stroke="white"
          strokeWidth="2"
          strokeLinecap="round"
          strokeLinejoin="round"
          fillOpacity="0.8"
        />
      </svg>
    </div>
  );
}

export function Logo({ size = "md", showText = false }: LogoProps) {
  return (
    <div
      className="logo"
      style={{ display: "flex", alignItems: "center", gap: showText ? 12 : 0 }}
    >
      <LogoMark size={size} />
      {showText && (
        <div className="logo__text">
          <span
            style={{
              display: "block",
              color: "#f0f5ff",
              fontSize:
                size === "sm" ? "0.95rem" : size === "md" ? "1.1rem" : "1.3rem",
              fontWeight: 700,
              lineHeight: 1.15,
              letterSpacing: "-0.02em",
            }}
          >
            Boilerplate
          </span>
          <span
            style={{
              display: "block",
              background:
                "linear-gradient(135deg, #667eea 0%, #f093fb 50%, #f5576c 100%)",
              WebkitBackgroundClip: "text",
              WebkitTextFillColor: "transparent",
              backgroundClip: "text",
              fontSize:
                size === "sm" ? "0.8rem" : size === "md" ? "0.9rem" : "1.05rem",
              fontWeight: 600,
              lineHeight: 1.2,
            }}
          >
            Projector
          </span>
        </div>
      )}
    </div>
  );
}

export function LogoIcon({ size = 32 }: { size?: number }) {
  return (
    <svg
      width={size}
      height={size}
      viewBox="0 0 24 24"
      fill="none"
      xmlns="http://www.w3.org/2000/svg"
    >
      <defs>
        <linearGradient
          id="logo-gradient"
          x1="0"
          y1="0"
          x2="24"
          y2="24"
          gradientUnits="userSpaceOnUse"
        >
          <stop offset="0%" stopColor="#667eea" />
          <stop offset="25%" stopColor="#764ba2" />
          <stop offset="50%" stopColor="#f093fb" />
          <stop offset="75%" stopColor="#f5576c" />
          <stop offset="100%" stopColor="#4facfe" />
        </linearGradient>
      </defs>
      <rect width="24" height="24" rx="6" fill="url(#logo-gradient)" />
      <path d="M12 4L4 8L12 12L20 8L12 4Z" fill="white" fillOpacity="0.95" />
      <path
        d="M4 12L12 16L20 12"
        stroke="white"
        strokeWidth="1.5"
        strokeLinecap="round"
        strokeLinejoin="round"
        opacity="0.9"
      />
      <path
        d="M4 16L12 20L20 16"
        stroke="white"
        strokeWidth="1.5"
        strokeLinecap="round"
        strokeLinejoin="round"
        opacity="0.8"
      />
    </svg>
  );
}
