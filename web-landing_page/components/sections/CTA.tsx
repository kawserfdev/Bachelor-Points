"use client";

import { Button } from "@/components/ui/button";
import { motion } from "framer-motion";
import { ArrowRight, Sparkles } from "lucide-react";

export function CTA() {
  return (
    <section className="py-20 lg:py-32 relative">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <motion.div
          initial={{ opacity: 0, y: 25 }}
          whileInView={{ opacity: 1, y: 0 }}
          viewport={{ once: true }}
          transition={{ duration: 0.5 }}
          className="relative rounded-3xl border border-white/15 bg-gradient-to-b from-[#181824] to-[#101018] overflow-hidden p-8 sm:p-16 lg:p-20 text-center shadow-[0_20px_80px_rgba(139,61,255,0.2)]"
        >
          {/* Ambient Lighting Background */}
          <div className="absolute inset-0 bg-grid-pattern opacity-40 pointer-events-none" />
          <div className="absolute top-0 left-1/2 -translate-x-1/2 w-[500px] h-[300px] bg-[#8B3DFF]/25 blur-[120px] rounded-full pointer-events-none" />

          <div className="relative max-w-3xl mx-auto space-y-6">
            <div className="inline-flex items-center gap-2 px-3.5 py-1.5 rounded-full bg-[#8B3DFF]/15 border border-[#8B3DFF]/30 text-xs font-bold text-[#C084FC]">
              <Sparkles className="w-3.5 h-3.5" />
              <span>Join Hundreds of Messes Across Bangladesh</span>
            </div>

            <h2 className="text-3xl sm:text-5xl lg:text-6xl font-extrabold tracking-tight text-foreground leading-[1.1] text-balance">
              Your Mess Deserves Better Than a Notebook.
            </h2>

            <p className="text-muted-foreground text-base sm:text-lg leading-relaxed max-w-xl mx-auto font-normal">
              Start managing meals, bazar, expenses, and balances the smarter way. Free to start, no setup fees, no complications.
            </p>

            <div className="flex flex-col sm:flex-row items-center justify-center gap-4 pt-4">
              <Button
                asChild
                size="lg"
                className="w-full sm:w-auto rounded-xl px-8 h-13 text-[15px] font-bold bg-gradient-to-r from-[#8B3DFF] to-[#A855F7] hover:opacity-95 text-white shadow-[0_0_40px_rgba(139,61,255,0.4)] border border-white/20 cursor-pointer"
              >
                <a href="/app/login" className="flex items-center justify-center gap-2">
                  <span>Create Your Mess — Free</span>
                  <ArrowRight className="w-4 h-4" />
                </a>
              </Button>
              <Button
                asChild
                size="lg"
                variant="outline"
                className="w-full sm:w-auto rounded-xl px-7 h-13 text-[15px] font-semibold border-border/80 bg-secondary/50 hover:bg-secondary text-foreground cursor-pointer"
              >
                <a href="#features">Explore BachelorPoints</a>
              </Button>
            </div>
          </div>
        </motion.div>
      </div>
    </section>
  );
}
