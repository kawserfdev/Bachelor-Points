"use client";

import { motion } from "framer-motion";
import { XCircle, CheckCircle2, BookOpen, Calculator, MessageSquareX, SearchX } from "lucide-react";

export function ProblemSolution() {
  const painPoints = [
    {
      icon: BookOpen,
      badge: "📒 Manual হিসাব",
      title: "Notebook & Calculator Chaos",
      desc: "Pages torn, handwriting unreadable, and manual calculator mistakes that take hours to resolve at month end.",
    },
    {
      icon: Calculator,
      badge: "🧮 Complex Calculations",
      title: "Meal Rate & Math Headaches",
      desc: "Splitting individual meal rates, guest meals, fixed utility bills, and bazar expenses without an automated formula.",
    },
    {
      icon: MessageSquareX,
      badge: "💬 Endless Arguments",
      title: '"আমি এত টাকা কেন দেব?"',
      desc: "Late-night disputes in the dining room over who ate what, who skipped meals, and who was wrongly charged.",
    },
    {
      icon: SearchX,
      badge: "🔎 No Financial Transparency",
      title: "Lost Receipts & Unsettled Dues",
      desc: "Nobody knows how much money is currently left in the mess fund or who owes overdue deposits.",
    },
  ];

  const beforeItems = [
    "Khata (খাতা) & physical paper records that get lost",
    "Manual calculator math prone to human error",
    "Mess group arguments on WhatsApp and Messenger",
    "Guest meals and portion fractions forgotten",
    "Unverified bazar receipts with no photo proof",
    "Confusing manual calculations at the end of each month",
  ];

  const afterItems = [
    "Instant digital meal logging with 0.5 to 2.0 portions",
    "100% automated meal rate and member balance calculations",
    "Clear, transparent balance sheets visible to all members",
    "Automated 8:00 AM bazar duty notifications & schedules",
    "Digital receipt uploads with manager verification queue",
    "One-click monthly PDF statement download and sharing",
  ];

  return (
    <section className="py-20 lg:py-28 relative">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        {/* Section Title */}
        <div className="text-center max-w-3xl mx-auto mb-16">
          <motion.span
            initial={{ opacity: 0, y: 10 }}
            whileInView={{ opacity: 1, y: 0 }}
            viewport={{ once: true }}
            className="text-xs font-bold uppercase tracking-widest text-[#8B3DFF] bg-[#8B3DFF]/10 px-3.5 py-1.5 rounded-full border border-[#8B3DFF]/20"
          >
            The Traditional Problem
          </motion.span>
          <motion.h2
            initial={{ opacity: 0, y: 15 }}
            whileInView={{ opacity: 1, y: 0 }}
            viewport={{ once: true }}
            transition={{ delay: 0.05 }}
            className="text-3xl sm:text-4xl lg:text-5xl font-extrabold tracking-tight mt-4 mb-4 text-balance"
          >
            Mess Management Shouldn&apos;t Be This Hard.
          </motion.h2>
          <motion.p
            initial={{ opacity: 0, y: 15 }}
            whileInView={{ opacity: 1, y: 0 }}
            viewport={{ once: true }}
            transition={{ delay: 0.1 }}
            className="text-muted-foreground text-base sm:text-lg leading-relaxed font-normal"
          >
            For decades, bachelor messes and student flats in Bangladesh have struggled with
            paper notebooks, lost receipts, and painful monthly calculations.
          </motion.p>
        </div>

        {/* 4 Problem Cards Grid */}
        <div className="grid sm:grid-cols-2 lg:grid-cols-4 gap-5 mb-20">
          {painPoints.map((point, index) => (
            <motion.div
              key={index}
              initial={{ opacity: 0, y: 20 }}
              whileInView={{ opacity: 1, y: 0 }}
              viewport={{ once: true }}
              transition={{ duration: 0.4, delay: index * 0.08 }}
              className="p-6 rounded-2xl bg-secondary/30 border border-border/60 hover:border-rose-500/30 transition-all flex flex-col justify-between"
            >
              <div>
                <div className="inline-flex items-center gap-1.5 text-xs font-bold text-rose-500 bg-rose-500/10 px-2.5 py-1 rounded-lg mb-4">
                  <span>{point.badge}</span>
                </div>
                <h3 className="text-base font-bold text-foreground mb-2">
                  {point.title}
                </h3>
                <p className="text-xs sm:text-sm text-muted-foreground leading-relaxed">
                  {point.desc}
                </p>
              </div>
            </motion.div>
          ))}
        </div>

        {/* Transition Header */}
        <div className="text-center max-w-2xl mx-auto mb-10">
          <span className="text-xs font-bold text-[#A855F7] tracking-wider uppercase">
            The Modern Solution
          </span>
          <h3 className="text-2xl sm:text-3xl font-extrabold text-foreground mt-1">
            BachelorPoints Changes Everything.
          </h3>
        </div>

        {/* Before vs After Comparison Grid */}
        <div className="grid lg:grid-cols-2 gap-6 max-w-5xl mx-auto">
          {/* Before Card */}
          <motion.div
            initial={{ opacity: 0, x: -20 }}
            whileInView={{ opacity: 1, x: 0 }}
            viewport={{ once: true }}
            transition={{ duration: 0.5 }}
            className="rounded-2xl border border-rose-500/20 bg-rose-500/[0.03] p-6 sm:p-8 relative overflow-hidden"
          >
            <div className="flex items-center gap-2.5 pb-4 mb-5 border-b border-rose-500/15">
              <div className="w-8 h-8 rounded-lg bg-rose-500/15 flex items-center justify-center">
                <XCircle className="w-4 h-4 text-rose-500" />
              </div>
              <div>
                <h4 className="text-sm font-bold text-rose-500 uppercase tracking-wider">
                  BEFORE — The Old Way
                </h4>
                <p className="text-xs text-muted-foreground">Notebooks, calculator, and confusion</p>
              </div>
            </div>

            <ul className="space-y-3">
              {beforeItems.map((item, i) => (
                <li key={i} className="flex items-start gap-3 text-xs sm:text-sm text-muted-foreground">
                  <span className="text-rose-500 font-bold shrink-0 mt-0.5">✕</span>
                  <span className="leading-snug">{item}</span>
                </li>
              ))}
            </ul>
          </motion.div>

          {/* After Card */}
          <motion.div
            initial={{ opacity: 0, x: 20 }}
            whileInView={{ opacity: 1, x: 0 }}
            viewport={{ once: true }}
            transition={{ duration: 0.5 }}
            className="rounded-2xl border border-[#8B3DFF]/30 bg-[#8B3DFF]/[0.04] p-6 sm:p-8 relative overflow-hidden shadow-[0_0_40px_rgba(139,61,255,0.1)]"
          >
            <div className="flex items-center gap-2.5 pb-4 mb-5 border-b border-[#8B3DFF]/20">
              <div className="w-8 h-8 rounded-lg bg-[#8B3DFF]/20 flex items-center justify-center">
                <CheckCircle2 className="w-4 h-4 text-[#8B3DFF]" />
              </div>
              <div>
                <h4 className="text-sm font-bold text-[#8B3DFF] uppercase tracking-wider">
                  AFTER — With BachelorPoints
                </h4>
                <p className="text-xs text-muted-foreground">Automated, transparent, and peaceful</p>
              </div>
            </div>

            <ul className="space-y-3">
              {afterItems.map((item, i) => (
                <li key={i} className="flex items-start gap-3 text-xs sm:text-sm text-foreground font-medium">
                  <CheckCircle2 className="w-4 h-4 text-emerald-500 shrink-0 mt-0.5" />
                  <span className="leading-snug">{item}</span>
                </li>
              ))}
            </ul>
          </motion.div>
        </div>
      </div>
    </section>
  );
}
