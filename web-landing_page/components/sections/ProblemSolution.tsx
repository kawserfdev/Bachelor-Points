"use client";

import { motion } from "framer-motion";
import { X, Check } from "lucide-react";

const problems = [
  "Manual ledger calculations that waste hours every month",
  "Endless arguments over who ate what and how much",
  "No real-time visibility into who paid and who owes",
  "Confusion when calculating monthly meal rates",
];

const solutions = [
  "Fully digital mess management — one tap to track everything",
  "Automatic meal rate and balance calculations, zero errors",
  "Transparent records so everyone trusts the process",
  "Live updates from any device, anytime, anywhere",
];

export function ProblemSolution() {
  return (
    <section className="py-20 lg:py-28 relative">
      <div className="max-w-6xl mx-auto px-5 sm:px-8">
        {/* Section header - left aligned for editorial feel */}
        <div className="max-w-2xl mb-14">
          <motion.span
            initial={{ opacity: 0, y: 10 }}
            whileInView={{ opacity: 1, y: 0 }}
            viewport={{ once: true }}
            className="text-[11px] font-bold uppercase tracking-widest text-primary"
          >
            The Problem vs. The Solution
          </motion.span>
          <motion.h2
            initial={{ opacity: 0, y: 15 }}
            whileInView={{ opacity: 1, y: 0 }}
            viewport={{ once: true }}
            transition={{ delay: 0.05 }}
            className="text-3xl sm:text-4xl font-extrabold tracking-[-0.02em] mt-4 mb-3 leading-[1.1]"
          >
            Mess life shouldn&apos;t feel
            <br />
            like a full-time job.
          </motion.h2>
          <motion.p
            initial={{ opacity: 0, y: 15 }}
            whileInView={{ opacity: 1, y: 0 }}
            viewport={{ once: true }}
            transition={{ delay: 0.1 }}
            className="text-muted-foreground text-[15px] leading-relaxed"
          >
            Bachelor messes in Bangladesh have relied on pen-and-paper for too
            long. Here&apos;s what changes when you go digital.
          </motion.p>
        </div>

        {/* Two-column comparison */}
        <div className="grid lg:grid-cols-2 gap-6">
          {/* Problem card */}
          <motion.div
            initial={{ opacity: 0, y: 25 }}
            whileInView={{ opacity: 1, y: 0 }}
            viewport={{ once: true }}
            transition={{ duration: 0.5 }}
            className="rounded-xl border border-red-500/10 bg-red-500/[0.02] p-6 sm:p-8"
          >
            <div className="flex items-center gap-2.5 mb-6">
              <div className="w-7 h-7 rounded-md bg-red-500/10 flex items-center justify-center">
                <X className="w-3.5 h-3.5 text-red-500" />
              </div>
              <h3 className="text-[13px] font-bold uppercase tracking-wider text-red-500">
                Before BachelorPoints
              </h3>
            </div>
            <ul className="space-y-3">
              {problems.map((p, i) => (
                <li
                  key={i}
                  className="flex items-start gap-3 p-3 rounded-lg bg-card border border-border/30"
                >
                  <div className="w-5 h-5 rounded-full bg-red-500/8 border border-red-500/10 flex items-center justify-center shrink-0 mt-0.5">
                    <X className="w-2.5 h-2.5 text-red-500" />
                  </div>
                  <span className="text-[13px] font-medium text-muted-foreground leading-snug">
                    {p}
                  </span>
                </li>
              ))}
            </ul>
          </motion.div>

          {/* Solution card */}
          <motion.div
            initial={{ opacity: 0, y: 25 }}
            whileInView={{ opacity: 1, y: 0 }}
            viewport={{ once: true }}
            transition={{ duration: 0.5, delay: 0.1 }}
            className="rounded-xl border border-primary/15 bg-primary/[0.02] p-6 sm:p-8"
          >
            <div className="flex items-center gap-2.5 mb-6">
              <div className="w-7 h-7 rounded-md bg-primary/10 flex items-center justify-center">
                <Check className="w-3.5 h-3.5 text-primary" />
              </div>
              <h3 className="text-[13px] font-bold uppercase tracking-wider text-primary">
                After BachelorPoints
              </h3>
            </div>
            <ul className="space-y-3">
              {solutions.map((s, i) => (
                <li
                  key={i}
                  className="flex items-start gap-3 p-3 rounded-lg bg-card border border-border/30"
                >
                  <div className="w-5 h-5 rounded-full bg-primary/8 border border-primary/10 flex items-center justify-center shrink-0 mt-0.5">
                    <Check className="w-2.5 h-2.5 text-primary" />
                  </div>
                  <span className="text-[13px] font-medium text-foreground leading-snug">
                    {s}
                  </span>
                </li>
              ))}
            </ul>
          </motion.div>
        </div>
      </div>
    </section>
  );
}
