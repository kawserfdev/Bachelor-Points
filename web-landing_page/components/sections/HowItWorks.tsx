"use client";

import { motion } from "framer-motion";
import { UserPlus, QrCode, UtensilsCrossed, FileSpreadsheet } from "lucide-react";

export function HowItWorks() {
  const steps = [
    {
      step: "01",
      icon: UserPlus,
      title: "Create Your Mess Group",
      desc: "Sign up in 30 seconds with Google or email, create your mess name, and generate your unique 6-digit invite code.",
      badge: "30 Seconds",
    },
    {
      step: "02",
      icon: QrCode,
      title: "Members Join Instantly",
      desc: "Share your code on WhatsApp. Flatmates join immediately on web or mobile with zero setup fee.",
      badge: "One Tap",
    },
    {
      step: "03",
      icon: UtensilsCrossed,
      title: "Track Meals & Bazar Daily",
      desc: "Members log breakfast, lunch, and dinner portions. Bazar expenses and deposit receipts are recorded in real-time.",
      badge: "Automated",
    },
    {
      step: "04",
      icon: FileSpreadsheet,
      title: "One-Click Month End Settle",
      desc: "BachelorPoints calculates meal rates, individual member costs, and generates official PDF reports for audit.",
      badge: "Zero Confusion",
    },
  ];

  return (
    <section id="how-it-works" className="py-20 lg:py-28 relative">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        {/* Header */}
        <div className="text-center max-w-3xl mx-auto mb-16 sm:mb-20">
          <motion.span
            initial={{ opacity: 0, y: 10 }}
            whileInView={{ opacity: 1, y: 0 }}
            viewport={{ once: true }}
            className="text-xs font-bold uppercase tracking-widest text-[#8B3DFF] bg-[#8B3DFF]/10 px-3.5 py-1.5 rounded-full border border-[#8B3DFF]/20"
          >
            Simple Onboarding
          </motion.span>
          <motion.h2
            initial={{ opacity: 0, y: 15 }}
            whileInView={{ opacity: 1, y: 0 }}
            viewport={{ once: true }}
            transition={{ delay: 0.05 }}
            className="text-3xl sm:text-4xl lg:text-5xl font-extrabold tracking-tight mt-4 mb-4 text-balance"
          >
            Four Steps to a Peaceful Mess Life.
          </motion.h2>
          <motion.p
            initial={{ opacity: 0, y: 15 }}
            whileInView={{ opacity: 1, y: 0 }}
            viewport={{ once: true }}
            transition={{ delay: 0.1 }}
            className="text-muted-foreground text-base sm:text-lg leading-relaxed font-normal"
          >
            Getting your entire mess onboard takes less than 2 minutes.
          </motion.p>
        </div>

        {/* 4 Steps Grid */}
        <div className="grid sm:grid-cols-2 lg:grid-cols-4 gap-6 relative">
          {steps.map((item, index) => {
            const Icon = item.icon;
            return (
              <motion.div
                key={index}
                initial={{ opacity: 0, y: 25 }}
                whileInView={{ opacity: 1, y: 0 }}
                viewport={{ once: true }}
                transition={{ duration: 0.4, delay: index * 0.1 }}
                className="relative rounded-2xl bg-card border border-border/70 p-6 sm:p-7 flex flex-col justify-between hover:border-[#8B3DFF]/40 transition-all shadow-sm"
              >
                <div>
                  <div className="flex items-center justify-between mb-5">
                    <span className="text-2xl font-black text-[#8B3DFF] font-mono opacity-80">
                      {item.step}
                    </span>
                    <span className="text-[10px] font-bold text-muted-foreground bg-secondary px-2.5 py-1 rounded-full border border-border/40">
                      {item.badge}
                    </span>
                  </div>

                  <div className="w-11 h-11 rounded-xl bg-[#8B3DFF]/15 text-[#8B3DFF] flex items-center justify-center mb-4">
                    <Icon className="w-5 h-5" />
                  </div>

                  <h3 className="text-lg font-bold text-foreground mb-2">
                    {item.title}
                  </h3>
                  <p className="text-xs sm:text-sm text-muted-foreground leading-relaxed">
                    {item.desc}
                  </p>
                </div>
              </motion.div>
            );
          })}
        </div>
      </div>
    </section>
  );
}
