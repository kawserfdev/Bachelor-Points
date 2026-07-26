"use client";

import { Button } from "@/components/ui/button";
import { motion } from "framer-motion";
import { ArrowRight } from "lucide-react";

export function CTA() {
  return (
    <section className="py-20 lg:py-28 relative">
      <div className="max-w-6xl mx-auto px-5 sm:px-8">
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          whileInView={{ opacity: 1, y: 0 }}
          viewport={{ once: true }}
          transition={{ duration: 0.5 }}
          className="relative rounded-2xl border border-border/40 bg-card overflow-hidden"
        >
          {/* Subtle background accents */}
          <div className="absolute inset-0 subtle-grid opacity-40 pointer-events-none" />
          <div className="absolute top-0 right-0 w-[300px] h-[300px] bg-primary/[0.04] blur-[80px] rounded-full pointer-events-none" />
          <div className="absolute bottom-0 left-0 w-[250px] h-[250px] bg-accent/[0.03] blur-[80px] rounded-full pointer-events-none" />

          <div className="relative px-8 py-16 sm:px-16 sm:py-20 text-center">
            <h2 className="text-3xl sm:text-4xl font-extrabold tracking-[-0.02em] mb-4 leading-[1.1]">
              Ready to simplify your mess life?
            </h2>
            <p className="text-muted-foreground text-[15px] leading-relaxed max-w-lg mx-auto mb-8">
              Join thousands of bachelor messes across Bangladesh who&apos;ve already
              replaced confusion with clarity. Start free — no strings attached.
            </p>

            <div className="flex flex-col sm:flex-row items-center justify-center gap-3">
              <Button
                asChild
                size="lg"
                className="rounded-lg px-6 h-11 text-[14px] font-semibold bg-primary hover:bg-primary/90 text-primary-foreground shadow-sm"
              >
                <a href="/app/login">
                  Get Started for Free
                  <ArrowRight className="ml-1.5 h-4 w-4" />
                </a>
              </Button>
              <Button
                asChild
                size="lg"
                variant="ghost"
                className="rounded-lg px-5 h-11 text-[14px] font-medium text-muted-foreground hover:text-foreground"
              >
                <a href="#features">Explore Features</a>
              </Button>
            </div>
          </div>
        </motion.div>
      </div>
    </section>
  );
}
