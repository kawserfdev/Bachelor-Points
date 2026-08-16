"use client";

import { motion } from "framer-motion";
import { ShieldCheck, Lock, Smartphone, RefreshCw, Cpu, CheckCircle } from "lucide-react";

export function TrustBenefits() {
  const trustPoints = [
    {
      icon: ShieldCheck,
      title: "100% Bangladesh Focused",
      desc: "Designed ground-up for Bangladeshi mess culture, with Taka (৳) currency, local meal patterns, and WhatsApp sharing.",
    },
    {
      icon: Lock,
      title: "Secure & Private Cloud",
      desc: "Your mess financials and meal logs are private. Only verified members in your group have access to records.",
    },
    {
      icon: RefreshCw,
      title: "Real-Time Synchronization",
      desc: "Instant live updates across all flatmates' phones whenever meals are changed, deposits logged, or expenses approved.",
    },
    {
      icon: Cpu,
      title: "Zero-Error Calculation Engine",
      desc: "Automated mathematical formulas calculate meal rates and individual balances without manual rounding errors.",
    },
    {
      icon: Smartphone,
      title: "Works on Any Device",
      desc: "Access your mess from Android, iOS, tablet, or modern web browser with identical real-time functionality.",
    },
    {
      icon: CheckCircle,
      title: "No Hidden Costs",
      desc: "Start free with all core mess management features. No credit card required, no surprise fees.",
    },
  ];

  return (
    <section className="py-20 lg:py-28 relative bg-secondary/15 border-y border-border/40">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        {/* Header */}
        <div className="text-center max-w-3xl mx-auto mb-16">
          <motion.span
            initial={{ opacity: 0, y: 10 }}
            whileInView={{ opacity: 1, y: 0 }}
            viewport={{ once: true }}
            className="text-xs font-bold uppercase tracking-widest text-[#8B3DFF] bg-[#8B3DFF]/10 px-3.5 py-1.5 rounded-full border border-[#8B3DFF]/20"
          >
            Built on Trust
          </motion.span>
          <motion.h2
            initial={{ opacity: 0, y: 15 }}
            whileInView={{ opacity: 1, y: 0 }}
            viewport={{ once: true }}
            transition={{ delay: 0.05 }}
            className="text-3xl sm:text-4xl lg:text-5xl font-extrabold tracking-tight mt-4 mb-4 text-balance"
          >
            Why Thousands of Mess Members Trust BachelorPoints.
          </motion.h2>
          <motion.p
            initial={{ opacity: 0, y: 15 }}
            whileInView={{ opacity: 1, y: 0 }}
            viewport={{ once: true }}
            transition={{ delay: 0.1 }}
            className="text-muted-foreground text-base sm:text-lg leading-relaxed font-normal"
          >
            Built with transparency, security, and simplicity at the very core.
          </motion.p>
        </div>

        {/* 6 Trust Cards */}
        <div className="grid sm:grid-cols-2 lg:grid-cols-3 gap-6">
          {trustPoints.map((point, index) => {
            const Icon = point.icon;
            return (
              <motion.div
                key={index}
                initial={{ opacity: 0, y: 20 }}
                whileInView={{ opacity: 1, y: 0 }}
                viewport={{ once: true }}
                transition={{ duration: 0.4, delay: index * 0.06 }}
                className="p-6 rounded-2xl bg-card border border-border/70 hover:border-[#8B3DFF]/30 transition-all flex flex-col justify-between"
              >
                <div>
                  <div className="w-10 h-10 rounded-xl bg-[#8B3DFF]/15 text-[#8B3DFF] flex items-center justify-center mb-4">
                    <Icon className="w-5 h-5" />
                  </div>
                  <h3 className="text-base font-bold text-foreground mb-2">
                    {point.title}
                  </h3>
                  <p className="text-xs sm:text-sm text-muted-foreground leading-relaxed">
                    {point.desc}
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
