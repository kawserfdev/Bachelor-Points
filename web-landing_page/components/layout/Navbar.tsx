"use client";

import Link from "next/link";
import { Button } from "@/components/ui/button";
import { Menu, X } from "lucide-react";
import { useState, useEffect } from "react";

export function Navbar() {
  const [isOpen, setIsOpen] = useState(false);
  const [scrolled, setScrolled] = useState(false);

  useEffect(() => {
    const onScroll = () => setScrolled(window.scrollY > 16);
    window.addEventListener("scroll", onScroll, { passive: true });
    return () => window.removeEventListener("scroll", onScroll);
  }, []);

  return (
    <header
      className={`fixed top-0 left-0 right-0 z-50 transition-all duration-300 ${
        scrolled
          ? "bg-background/80 backdrop-blur-xl border-b border-border/50 shadow-[0_1px_3px_rgba(0,0,0,0.04)]"
          : "bg-transparent"
      }`}
    >
      <nav className="max-w-6xl mx-auto px-5 sm:px-8 h-16 flex items-center justify-between">
        {/* Logo */}
        <Link href="/" className="flex items-center gap-2.5 group">
          <div className="w-8 h-8 rounded-lg bg-primary flex items-center justify-center shadow-sm">
            <svg className="w-4.5 h-4.5" viewBox="0 0 24 24" fill="none">
              <circle cx="9" cy="12" r="5" fill="white" />
              <circle cx="15" cy="12" r="5" fill="white" fillOpacity="0.5" />
            </svg>
          </div>
          <span className="text-[15px] font-bold tracking-[-0.01em] text-foreground">
            Bachelor<span className="text-muted-foreground font-medium">Points</span>
          </span>
        </Link>

        {/* Desktop */}
        <div className="hidden md:flex items-center gap-7">
          <Link
            href="#features"
            className="text-[13px] font-medium text-muted-foreground hover:text-foreground transition-colors"
          >
            Features
          </Link>
          <Link
            href="#how-it-works"
            className="text-[13px] font-medium text-muted-foreground hover:text-foreground transition-colors"
          >
            How it Works
          </Link>
          <Link
            href="#faq"
            className="text-[13px] font-medium text-muted-foreground hover:text-foreground transition-colors"
          >
            FAQ
          </Link>

          <div className="w-px h-4 bg-border mx-1" />

          <Link
            href="/app/login"
            className="text-[13px] font-medium text-muted-foreground hover:text-foreground transition-colors"
          >
            Log in
          </Link>
          <Button
            asChild
            size="sm"
            className="rounded-lg px-4 h-9 text-[13px] font-semibold bg-primary hover:bg-primary/90 text-primary-foreground shadow-sm"
          >
            <a href="/app/login">Get Started</a>
          </Button>
        </div>

        {/* Mobile toggle */}
        <button
          onClick={() => setIsOpen(!isOpen)}
          className="md:hidden p-2 -mr-2 text-muted-foreground hover:text-foreground transition-colors"
          aria-label="Toggle menu"
        >
          {isOpen ? <X className="h-5 w-5" /> : <Menu className="h-5 w-5" />}
        </button>
      </nav>

      {/* Mobile menu */}
      {isOpen && (
        <div className="md:hidden bg-background/95 backdrop-blur-xl border-b border-border/50 px-5 pb-5 pt-2">
          <div className="flex flex-col gap-1">
            <Link
              href="#features"
              onClick={() => setIsOpen(false)}
              className="px-3 py-2.5 rounded-lg text-[14px] font-medium text-muted-foreground hover:text-foreground hover:bg-secondary transition-all"
            >
              Features
            </Link>
            <Link
              href="#how-it-works"
              onClick={() => setIsOpen(false)}
              className="px-3 py-2.5 rounded-lg text-[14px] font-medium text-muted-foreground hover:text-foreground hover:bg-secondary transition-all"
            >
              How it Works
            </Link>
            <Link
              href="#faq"
              onClick={() => setIsOpen(false)}
              className="px-3 py-2.5 rounded-lg text-[14px] font-medium text-muted-foreground hover:text-foreground hover:bg-secondary transition-all"
            >
              FAQ
            </Link>
            <div className="h-px bg-border/50 my-2" />
            <Link
              href="/app/login"
              onClick={() => setIsOpen(false)}
              className="px-3 py-2.5 rounded-lg text-[14px] font-medium text-muted-foreground hover:text-foreground hover:bg-secondary transition-all"
            >
              Log in
            </Link>
            <Button
              asChild
              className="mt-1 rounded-lg h-10 text-[14px] font-semibold bg-primary text-primary-foreground"
            >
              <a href="/app/login">Get Started</a>
            </Button>
          </div>
        </div>
      )}
    </header>
  );
}
