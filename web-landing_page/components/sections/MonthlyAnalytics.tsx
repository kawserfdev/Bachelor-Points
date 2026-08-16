"use client";

import { motion } from "framer-motion";
import { TrendingUp, DollarSign, Users, Utensils } from "lucide-react";

export function MonthlyAnalytics() {
  const expenseCategories = [
    { label: "Daily Bazar & Groceries", amount: "৳68,450", percentage: "60.3%", color: "bg-[#8B3DFF]" },
    { label: "House Rent & Service", amount: "৳32,000", percentage: "28.2%", color: "bg-[#A855F7]" },
    { label: "Electricity & Gas Bills", amount: "৳7,841", percentage: "6.9%", color: "bg-amber-500" },
    { label: "High-Speed WiFi & Others", amount: "৳5,200", percentage: "4.6%", color: "bg-cyan-500" },
  ];

  return (
    <section className="py-20 lg:py-28 relative">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        {/* Header */}
        <div className="text-center max-w-3xl mx-auto mb-16">
          <motion.span
            initial={{ opacity: 0, y: 10 }}
            whileInView={{ opacity: 1, y: 0 }}
            viewport={{ once: true }}
            className="text-xs font-bold uppercase tracking-widest text-cyan-500 bg-cyan-500/10 px-3.5 py-1.5 rounded-full border border-cyan-500/20"
          >
            Financial Analytics
          </motion.span>
          <motion.h2
            initial={{ opacity: 0, y: 15 }}
            whileInView={{ opacity: 1, y: 0 }}
            viewport={{ once: true }}
            transition={{ delay: 0.05 }}
            className="text-3xl sm:text-4xl lg:text-5xl font-extrabold tracking-tight mt-4 mb-4 text-balance"
          >
            Your Entire Month. Clear Financial Visibility.
          </motion.h2>
          <motion.p
            initial={{ opacity: 0, y: 15 }}
            whileInView={{ opacity: 1, y: 0 }}
            viewport={{ once: true }}
            transition={{ delay: 0.1 }}
            className="text-muted-foreground text-base sm:text-lg leading-relaxed font-normal"
          >
            Instant visual breakdowns of where your mess money goes every single month.
          </motion.p>
        </div>

        {/* 4 Summary Stat Cards */}
        <div className="grid grid-cols-2 lg:grid-cols-4 gap-4 sm:gap-5 mb-8">
          <motion.div
            initial={{ opacity: 0, y: 15 }}
            whileInView={{ opacity: 1, y: 0 }}
            viewport={{ once: true }}
            className="p-5 rounded-2xl bg-card border border-border/70"
          >
            <div className="flex items-center justify-between text-muted-foreground mb-2">
              <span className="text-xs font-semibold uppercase tracking-wider">Total Meals</span>
              <Utensils className="w-4 h-4 text-[#8B3DFF]" />
            </div>
            <div className="text-2xl sm:text-3xl font-extrabold text-foreground tracking-tight">
              528.0
            </div>
            <span className="text-[11px] text-muted-foreground font-medium mt-1 block">
              Across 30 days
            </span>
          </motion.div>

          <motion.div
            initial={{ opacity: 0, y: 15 }}
            whileInView={{ opacity: 1, y: 0 }}
            viewport={{ once: true }}
            transition={{ delay: 0.05 }}
            className="p-5 rounded-2xl bg-card border border-border/70"
          >
            <div className="flex items-center justify-between text-muted-foreground mb-2">
              <span className="text-xs font-semibold uppercase tracking-wider">Total Expenses</span>
              <DollarSign className="w-4 h-4 text-rose-500" />
            </div>
            <div className="text-2xl sm:text-3xl font-extrabold text-foreground tracking-tight font-mono">
              ৳113,491
            </div>
            <span className="text-[11px] text-muted-foreground font-medium mt-1 block">
              All shared costs logged
            </span>
          </motion.div>

          <motion.div
            initial={{ opacity: 0, y: 15 }}
            whileInView={{ opacity: 1, y: 0 }}
            viewport={{ once: true }}
            transition={{ delay: 0.1 }}
            className="p-5 rounded-2xl bg-card border border-[#8B3DFF]/30 bg-[#8B3DFF]/[0.03]"
          >
            <div className="flex items-center justify-between text-muted-foreground mb-2">
              <span className="text-xs font-semibold uppercase tracking-wider">Final Meal Rate</span>
              <TrendingUp className="w-4 h-4 text-[#8B3DFF]" />
            </div>
            <div className="text-2xl sm:text-3xl font-extrabold text-[#8B3DFF] tracking-tight font-mono">
              ৳214.37
            </div>
            <span className="text-[11px] text-emerald-500 font-semibold mt-1 block">
              Automated formula match
            </span>
          </motion.div>

          <motion.div
            initial={{ opacity: 0, y: 15 }}
            whileInView={{ opacity: 1, y: 0 }}
            viewport={{ once: true }}
            transition={{ delay: 0.15 }}
            className="p-5 rounded-2xl bg-card border border-border/70"
          >
            <div className="flex items-center justify-between text-muted-foreground mb-2">
              <span className="text-xs font-semibold uppercase tracking-wider">Mess Members</span>
              <Users className="w-4 h-4 text-cyan-500" />
            </div>
            <div className="text-2xl sm:text-3xl font-extrabold text-foreground tracking-tight">
              10
            </div>
            <span className="text-[11px] text-muted-foreground font-medium mt-1 block">
              100% accounts audited
            </span>
          </motion.div>
        </div>

        {/* Expense Category Breakdown & Settlement Bar */}
        <div className="p-6 sm:p-8 rounded-3xl bg-card border border-border/70 shadow-sm">
          <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-3 mb-6">
            <div>
              <h3 className="text-lg font-bold text-foreground">
                Monthly Expense Allocation
              </h3>
              <p className="text-xs text-muted-foreground">
                Categorized spending breakdown with percentage share
              </p>
            </div>
            <span className="text-xs font-mono font-semibold text-muted-foreground bg-secondary px-3 py-1 rounded-lg">
              Total: ৳113,491.00
            </span>
          </div>

          {/* Color Progress Bar */}
          <div className="h-3.5 w-full rounded-full bg-secondary overflow-hidden flex gap-1 p-0.5 mb-6">
            <div className="h-full rounded-full bg-[#8B3DFF] w-[60.3%]" title="Bazar 60.3%" />
            <div className="h-full rounded-full bg-[#A855F7] w-[28.2%]" title="Rent 28.2%" />
            <div className="h-full rounded-full bg-amber-500 w-[6.9%]" title="Utilities 6.9%" />
            <div className="h-full rounded-full bg-cyan-500 w-[4.6%]" title="WiFi & Others 4.6%" />
          </div>

          {/* Expense Category Cards */}
          <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4 text-xs">
            {expenseCategories.map((cat, i) => (
              <div key={i} className="p-3.5 rounded-xl bg-secondary/50 border border-border/40">
                <div className="flex items-center gap-2 mb-1.5">
                  <span className={`w-2.5 h-2.5 rounded-full ${cat.color}`} />
                  <span className="font-semibold text-foreground">{cat.label}</span>
                </div>
                <div className="flex items-center justify-between">
                  <span className="font-extrabold text-sm text-foreground font-mono">{cat.amount}</span>
                  <span className="text-muted-foreground font-semibold">{cat.percentage}</span>
                </div>
              </div>
            ))}
          </div>
        </div>
      </div>
    </section>
  );
}
