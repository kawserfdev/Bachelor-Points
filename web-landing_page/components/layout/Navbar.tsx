"use client";

import Link from "next/link";
import { Button } from "@/components/ui/button";
import { ThemeToggle } from "@/components/ui/theme-toggle";
import { Menu, X, ArrowRight, Sparkles } from "lucide-react";
import { useState, useEffect } from "react";

export function Navbar() {
  const [isOpen, setIsOpen] = useState(false);
  const [scrolled, setScrolled] = useState(false);

  useEffect(() => {
    const onScroll = () => setScrolled(window.scrollY > 20);
    window.addEventListener("scroll", onScroll, { passive: true });
    return () => window.removeEventListener("scroll", onScroll);
  }, []);

  const navLinks = [
    { label: "Features", href: "#features" },
    { label: "How It Works", href: "#how-it-works" },
    { label: "Product Demo", href: "#product-demo" },
    { label: "Smart Bazar", href: "#smart-bazar" },
    { label: "Manager Control", href: "#manager-control" },
    { label: "FAQ", href: "#faq" },
  ];

  return (
    <header
      className={`fixed top-0 left-0 right-0 z-50 transition-all duration-300 ${
        scrolled
          ? "bg-background/80 backdrop-blur-xl border-b border-border shadow-[0_4px_30px_rgba(0,0,0,0.1)] py-3"
          : "bg-transparent py-4 sm:py-5"
      }`}
    >
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div className="flex items-center justify-between">
          {/* Brand Logo */}
          <Link href="/" className="flex items-center gap-3 group">
            <div className="w-9 h-9 rounded-xl bg-gradient-to-tr from-[#8B3DFF] to-[#A855F7] p-0.5 flex items-center justify-center shadow-[0_0_20px_rgba(139,61,255,0.35)] group-hover:scale-105 transition-transform">
              <div className="w-full h-full bg-[#0A0A0F] rounded-[10px] flex items-center justify-center">
                <svg className="w-5 h-5" viewBox="0 0 24 24" fill="none">
                  <path
                    d="M12 2L2 7L12 12L22 7L12 2Z"
                    stroke="#C084FC"
                    strokeWidth="2"
                    strokeLinecap="round"
                    strokeLinejoin="round"
                  />
                  <path
                    d="M2 17L12 22L22 17"
                    stroke="#8B3DFF"
                    strokeWidth="2"
                    strokeLinecap="round"
                    strokeLinejoin="round"
                  />
                  <path
                    d="M2 12L12 17L22 12"
                    stroke="#A855F7"
                    strokeWidth="2"
                    strokeLinecap="round"
                    strokeLinejoin="round"
                  />
                </svg>
              </div>
            </div>
            <div className="flex flex-col">
              <span className="text-[17px] font-extrabold tracking-tight text-foreground flex items-center gap-1.5">
                Bachelor<span className="text-[#A855F7]">Points</span>
              </span>
              <span className="text-[9px] font-medium text-muted-foreground tracking-wider uppercase -mt-1 hidden sm:block">
                Mess Management SaaS
              </span>
            </div>
          </Link>

          {/* Desktop Navigation Links */}
          <nav className="hidden lg:flex items-center gap-1 bg-secondary/40 border border-border/40 px-3 py-1.5 rounded-full backdrop-blur-md">
            {navLinks.map((link) => (
              <Link
                key={link.label}
                href={link.href}
                className="px-3.5 py-1.5 text-[13px] font-medium text-muted-foreground hover:text-foreground hover:bg-secondary/70 rounded-full transition-all"
              >
                {link.label}
              </Link>
            ))}
          </nav>

          {/* Desktop CTA & Controls */}
          <div className="hidden sm:flex items-center gap-3">
            <ThemeToggle />

            <Link
              href="/app/login"
              className="text-[13px] font-semibold text-muted-foreground hover:text-foreground px-3 py-2 transition-colors"
            >
              Log in
            </Link>

            <Button
              asChild
              className="rounded-xl px-5 h-10 text-[13px] font-semibold bg-gradient-to-r from-[#8B3DFF] to-[#A855F7] hover:opacity-90 text-white shadow-[0_0_25px_rgba(139,61,255,0.35)] border border-white/10 cursor-pointer"
            >
              <a href="/app/login" className="flex items-center gap-1.5">
                <span>Get Started Free</span>
                <ArrowRight className="w-3.5 h-3.5" />
              </a>
            </Button>
          </div>

          {/* Mobile Menu & Theme Toggle */}
          <div className="flex items-center gap-2 lg:hidden">
            <ThemeToggle />
            <button
              onClick={() => setIsOpen(!isOpen)}
              className="p-2.5 rounded-xl bg-secondary/80 border border-border/60 text-foreground hover:bg-secondary transition-colors"
              aria-label="Toggle menu"
            >
              {isOpen ? <X className="h-5 w-5" /> : <Menu className="h-5 w-5" />}
            </button>
          </div>
        </div>
      </div>

      {/* Mobile Drawer Menu */}
      {isOpen && (
        <div className="lg:hidden bg-background/95 backdrop-blur-2xl border-b border-border px-5 py-6 mt-3 shadow-2xl animate-in slide-in-from-top-4 duration-200">
          <div className="flex flex-col gap-2">
            <div className="pb-2 mb-2 border-b border-border/50 flex items-center justify-between">
              <span className="text-xs font-semibold text-muted-foreground uppercase tracking-wider">
                Menu
              </span>
              <span className="inline-flex items-center gap-1 text-[11px] font-semibold text-emerald-500 bg-emerald-500/10 px-2 py-0.5 rounded-full">
                <Sparkles className="w-3 h-3" /> 100% Free Core
              </span>
            </div>

            {navLinks.map((link) => (
              <Link
                key={link.label}
                href={link.href}
                onClick={() => setIsOpen(false)}
                className="px-3.5 py-2.5 rounded-xl text-[14px] font-semibold text-muted-foreground hover:text-foreground hover:bg-secondary/70 transition-all flex items-center justify-between"
              >
                <span>{link.label}</span>
                <span className="text-muted-foreground/40 text-xs">→</span>
              </Link>
            ))}

            <div className="h-px bg-border/60 my-3" />

            <div className="grid grid-cols-2 gap-2.5 pt-1">
              <Link
                href="/app/login"
                onClick={() => setIsOpen(false)}
                className="w-full text-center py-2.5 rounded-xl text-[14px] font-semibold bg-secondary text-foreground hover:bg-secondary/80 border border-border/50"
              >
                Log in
              </Link>
              <Button
                asChild
                className="w-full rounded-xl h-11 text-[14px] font-semibold bg-gradient-to-r from-[#8B3DFF] to-[#A855F7] text-white shadow-lg shadow-[#8B3DFF]/25"
              >
                <a href="/app/login" onClick={() => setIsOpen(false)}>
                  Get Started
                </a>
              </Button>
            </div>
          </div>
        </div>
      )}
    </header>
  );
}
