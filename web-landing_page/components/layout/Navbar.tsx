"use client";

import Link from "next/link";
import { Button } from "@/components/ui/button";
import { motion } from "framer-motion";
import { Menu, X } from "lucide-react";
import { useState } from "react";

export function Navbar() {
  const [isOpen, setIsOpen] = useState(false);

  return (
    <motion.nav
      initial={{ y: -100 }}
      animate={{ y: 0 }}
      className="fixed top-0 left-0 right-0 z-50 glass border-b border-border/50"
    >
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div className="flex justify-between items-center h-16">
          <div className="flex items-center">
            <Link href="/" className="flex items-center space-x-2">
              <span className="text-2xl font-bold bg-clip-text text-transparent bg-gradient-to-r from-primary to-primary/60">
                BachelorPoints
              </span>
            </Link>
          </div>

          {/* Desktop Menu */}
          <div className="hidden md:flex items-center space-x-8">
            <Link href="#features" className="text-sm font-medium text-muted-foreground hover:text-primary transition-colors">
              Features
            </Link>
            <Link href="#how-it-works" className="text-sm font-medium text-muted-foreground hover:text-primary transition-colors">
              How it Works
            </Link>
            <Link href="#faq" className="text-sm font-medium text-muted-foreground hover:text-primary transition-colors">
              FAQ
            </Link>
            <Button asChild variant="ghost" className="text-sm font-medium">
              <a href="/app/login">Login</a>
            </Button>
            <Button asChild className="rounded-full px-6">
              <a href="/app/login">Get Started</a>
            </Button>
          </div>

          {/* Mobile Menu Button */}
          <div className="md:hidden flex items-center">
            <button
              onClick={() => setIsOpen(!isOpen)}
              className="text-muted-foreground hover:text-primary"
            >
              {isOpen ? <X className="h-6 w-6" /> : <Menu className="h-6 w-6" />}
            </button>
          </div>
        </div>
      </div>

      {/* Mobile Menu */}
      {isOpen && (
        <motion.div
          initial={{ opacity: 0, y: -20 }}
          animate={{ opacity: 1, y: 0 }}
          className="md:hidden glass border-t border-border/50 px-4 pt-2 pb-6 space-y-4"
        >
          <Link
            href="#features"
            className="block text-base font-medium text-muted-foreground hover:text-primary"
            onClick={() => setIsOpen(false)}
          >
            Features
          </Link>
          <Link
            href="#how-it-works"
            className="block text-base font-medium text-muted-foreground hover:text-primary"
            onClick={() => setIsOpen(false)}
          >
            How it Works
          </Link>
          <Link
            href="#faq"
            className="block text-base font-medium text-muted-foreground hover:text-primary"
            onClick={() => setIsOpen(false)}
          >
            FAQ
          </Link>
          <div className="flex flex-col space-y-2 pt-4">
            <Button asChild variant="outline" className="w-full">
              <a href="/app/login">Login</a>
            </Button>
            <Button asChild className="w-full">
              <a href="/app/login">Get Started</a>
            </Button>
          </div>
        </motion.div>
      )}
    </motion.nav>
  );
}
