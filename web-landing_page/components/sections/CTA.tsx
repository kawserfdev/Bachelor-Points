"use client";

import { Button } from "@/components/ui/button";
import { motion } from "framer-motion";
import { ArrowRight } from "lucide-react";

export function CTA() {
  return (
    <section className="py-24 relative overflow-hidden">
      <div className="absolute inset-0 bg-primary/5 -z-10" />
      <div className="max-w-5xl mx-auto px-4 sm:px-6 lg:px-8">
        <motion.div
          initial={{ opacity: 0, scale: 0.95 }}
          whileInView={{ opacity: 1, scale: 1 }}
          viewport={{ once: true }}
          className="bg-primary rounded-[3rem] p-12 md:p-20 text-center text-primary-foreground relative overflow-hidden shadow-2xl shadow-primary/20"
        >
          {/* Decorative circles */}
          <div className="absolute top-0 left-0 w-64 h-64 bg-white/10 rounded-full -translate-x-1/2 -translate-y-1/2 blur-3xl" />
          <div className="absolute bottom-0 right-0 w-64 h-64 bg-white/10 rounded-full translate-x-1/2 translate-y-1/2 blur-3xl" />

          <h2 className="text-3xl md:text-5xl font-bold mb-6">
            আজই আপনার মেসের হিসাব সহজ করুন
          </h2>
          <p className="text-primary-foreground/80 text-lg md:text-xl mb-10 max-w-2xl mx-auto leading-relaxed">
            হাজারো ব্যাসেলর অলরেডি Mess Manager ব্যবহার করে তাদের লাইফ সহজ করে ফেলেছে। আপনি কেন পিছিয়ে থাকবেন?
          </p>
          <div className="flex flex-col sm:flex-row items-center justify-center gap-4">
            <Button size="lg" variant="secondary" className="rounded-full px-8 h-14 text-lg group bg-white text-primary hover:bg-zinc-100 border-none">
              Get Started for Free
              <ArrowRight className="ml-2 h-5 w-5 group-hover:translate-x-1 transition-transform" />
            </Button>
            <Button size="lg" variant="outline" className="rounded-full px-8 h-14 text-lg border-white/20 text-white hover:bg-white/10">
              Contact Sales
            </Button>
          </div>
        </motion.div>
      </div>
    </section>
  );
}
