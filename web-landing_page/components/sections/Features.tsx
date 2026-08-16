"use client";

import { useState } from "react";
import { motion } from "framer-motion";
import {
  Receipt,
  ShoppingBag,
  Wallet,
  Calculator,
  WifiOff,
  Bell,
  FileText,
  Check,
  Sparkles,
  Download,
} from "lucide-react";

export function Features() {
  const [calcMeals, setCalcMeals] = useState<number>(30);
  const [calcRate, setCalcRate] = useState<number>(45);
  const [calcDeposit, setCalcDeposit] = useState<number>(2000);

  const calcCost = calcMeals * calcRate;
  const calcBalance = calcDeposit - calcCost;

  return (
    <section id="features" className="py-20 lg:py-32 relative">
      {/* Background decoration */}
      <div className="absolute top-1/3 left-0 w-96 h-96 bg-[#8B3DFF]/10 blur-[140px] rounded-full pointer-events-none" />
      <div className="absolute bottom-10 right-0 w-96 h-96 bg-[#A855F7]/10 blur-[140px] rounded-full pointer-events-none" />

      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 relative">
        {/* Section Header */}
        <div className="text-center max-w-3xl mx-auto mb-16 sm:mb-20">
          <motion.span
            initial={{ opacity: 0, y: 10 }}
            whileInView={{ opacity: 1, y: 0 }}
            viewport={{ once: true }}
            className="text-xs font-bold uppercase tracking-widest text-[#8B3DFF] bg-[#8B3DFF]/10 px-3.5 py-1.5 rounded-full border border-[#8B3DFF]/20"
          >
            Feature Showcase
          </motion.span>
          <motion.h2
            initial={{ opacity: 0, y: 15 }}
            whileInView={{ opacity: 1, y: 0 }}
            viewport={{ once: true }}
            transition={{ delay: 0.05 }}
            className="text-3xl sm:text-4xl lg:text-5xl font-extrabold tracking-tight mt-4 mb-4"
          >
            Everything Your Mess Needs.
          </motion.h2>
          <motion.p
            initial={{ opacity: 0, y: 15 }}
            whileInView={{ opacity: 1, y: 0 }}
            viewport={{ once: true }}
            transition={{ delay: 0.1 }}
            className="text-muted-foreground text-base sm:text-lg leading-relaxed font-normal"
          >
            From today&apos;s meal count to the end-of-month settlement, BachelorPoints handles it all.
          </motion.p>
        </div>

        {/* Feature Grid - Large 8 Cards */}
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
          {/* FEATURE 01 — MEAL MANAGEMENT */}
          <motion.div
            initial={{ opacity: 0, y: 25 }}
            whileInView={{ opacity: 1, y: 0 }}
            viewport={{ once: true }}
            className="rounded-2xl bg-card border border-border/70 p-6 sm:p-7 flex flex-col justify-between hover:border-[#8B3DFF]/40 transition-all shadow-sm"
          >
            <div>
              <div className="w-12 h-12 rounded-xl bg-[#8B3DFF]/15 text-[#8B3DFF] flex items-center justify-center mb-5 text-xl">
                🍛
              </div>
              <span className="text-[11px] font-bold text-[#8B3DFF] uppercase tracking-wider block mb-1">
                Feature 01
              </span>
              <h3 className="text-xl font-bold text-foreground mb-2">
                Meals, Made Simple.
              </h3>
              <p className="text-xs sm:text-sm text-muted-foreground leading-relaxed mb-4">
                Add breakfast, lunch, dinner, and guest meals in seconds. Flexible portions with automatic cut-off locking.
              </p>

              <div className="p-3 rounded-xl bg-secondary/60 border border-border/40 space-y-2 mb-4">
                <div className="flex items-center justify-between text-xs font-semibold">
                  <span className="text-muted-foreground">Supported Portions:</span>
                  <div className="flex gap-1">
                    {["0.5", "1.0", "1.5", "2.0"].map((p) => (
                      <span key={p} className="px-1.5 py-0.5 rounded bg-background text-[11px] font-bold text-[#8B3DFF]">
                        {p}
                      </span>
                    ))}
                  </div>
                </div>
                <div className="flex items-center justify-between text-xs font-medium text-muted-foreground">
                  <span>Guest meals supported</span>
                  <span className="text-emerald-500 font-bold">✓ Active</span>
                </div>
                <div className="flex items-center justify-between text-xs font-medium text-muted-foreground">
                  <span>Auto-lock at cutoff</span>
                  <span className="text-foreground font-semibold">10:00 PM</span>
                </div>
              </div>
            </div>

            <ul className="space-y-1.5 pt-2 border-t border-border/40 text-xs text-muted-foreground">
              <li className="flex items-center gap-2">
                <Check className="w-3.5 h-3.5 text-[#8B3DFF]" /> Custom portion sizes per meal
              </li>
              <li className="flex items-center gap-2">
                <Check className="w-3.5 h-3.5 text-[#8B3DFF]" /> Separate breakfast, lunch & dinner
              </li>
            </ul>
          </motion.div>

          {/* FEATURE 02 — EXPENSE MANAGEMENT */}
          <motion.div
            initial={{ opacity: 0, y: 25 }}
            whileInView={{ opacity: 1, y: 0 }}
            viewport={{ once: true }}
            transition={{ delay: 0.1 }}
            className="rounded-2xl bg-card border border-border/70 p-6 sm:p-7 flex flex-col justify-between hover:border-rose-500/40 transition-all shadow-sm"
          >
            <div>
              <div className="w-12 h-12 rounded-xl bg-rose-500/15 text-rose-500 flex items-center justify-center mb-5">
                <Receipt className="w-6 h-6" />
              </div>
              <span className="text-[11px] font-bold text-rose-500 uppercase tracking-wider block mb-1">
                Feature 02
              </span>
              <h3 className="text-xl font-bold text-foreground mb-2">
                Every Taka, Accounted For.
              </h3>
              <p className="text-xs sm:text-sm text-muted-foreground leading-relaxed mb-4">
                Record bazar, house rent, WiFi bills, and other shared expenses with complete receipts and transparency.
              </p>

              <div className="p-3 rounded-xl bg-secondary/60 border border-border/40 space-y-2 mb-4">
                <div className="flex items-center justify-between text-xs font-semibold">
                  <span>Oil, Dal & Fish</span>
                  <span className="text-rose-500 font-extrabold font-mono">৳1,450</span>
                </div>
                <div className="flex items-center justify-between text-[11px] text-muted-foreground">
                  <span>By Zahid Hasan • Bazar</span>
                  <span className="text-[9px] font-bold px-1.5 py-0.2 rounded bg-emerald-500/15 text-emerald-600 dark:text-emerald-400">
                    Approved
                  </span>
                </div>
              </div>
            </div>

            <ul className="space-y-1.5 pt-2 border-t border-border/40 text-xs text-muted-foreground">
              <li className="flex items-center gap-2">
                <Check className="w-3.5 h-3.5 text-rose-500" /> Category-based tagging (Bazar, Utilities, Rent)
              </li>
              <li className="flex items-center gap-2">
                <Check className="w-3.5 h-3.5 text-rose-500" /> Manager review and approval queue
              </li>
            </ul>
          </motion.div>

          {/* FEATURE 03 — BAZAR MANAGEMENT */}
          <motion.div
            initial={{ opacity: 0, y: 25 }}
            whileInView={{ opacity: 1, y: 0 }}
            viewport={{ once: true }}
            transition={{ delay: 0.2 }}
            className="rounded-2xl bg-card border border-border/70 p-6 sm:p-7 flex flex-col justify-between hover:border-amber-500/40 transition-all shadow-sm"
          >
            <div>
              <div className="w-12 h-12 rounded-xl bg-amber-500/15 text-amber-500 flex items-center justify-center mb-5">
                <ShoppingBag className="w-6 h-6" />
              </div>
              <span className="text-[11px] font-bold text-amber-500 uppercase tracking-wider block mb-1">
                Feature 03
              </span>
              <h3 className="text-xl font-bold text-foreground mb-2">
                Never Forget Your Bazar Duty.
              </h3>
              <p className="text-xs sm:text-sm text-muted-foreground leading-relaxed mb-4">
                Assign bazar duty on an automated calendar. Know what to buy, know who&apos;s going, and know when.
              </p>

              <div className="p-3 rounded-xl bg-secondary/60 border border-border/40 space-y-1.5 mb-4">
                <div className="flex items-center justify-between text-xs font-semibold text-foreground">
                  <span>Assigned: Kawser Ahmed</span>
                  <span className="text-amber-500 text-[11px]">18 August</span>
                </div>
                <p className="text-[11px] text-muted-foreground">
                  Reminder set for 8:00 AM on duty day
                </p>
                <div className="text-[10px] text-[#8B3DFF] font-semibold">
                  Items: Rice, Potatoes, Eggs, Oil, Onion
                </div>
              </div>
            </div>

            <ul className="space-y-1.5 pt-2 border-t border-border/40 text-xs text-muted-foreground">
              <li className="flex items-center gap-2">
                <Check className="w-3.5 h-3.5 text-amber-500" /> Interactive checklist for shopping items
              </li>
              <li className="flex items-center gap-2">
                <Check className="w-3.5 h-3.5 text-amber-500" /> Push reminders on duty mornings
              </li>
            </ul>
          </motion.div>

          {/* FEATURE 04 — DEPOSIT & BALANCE */}
          <motion.div
            initial={{ opacity: 0, y: 25 }}
            whileInView={{ opacity: 1, y: 0 }}
            viewport={{ once: true }}
            className="rounded-2xl bg-card border border-border/70 p-6 sm:p-7 flex flex-col justify-between hover:border-emerald-500/40 transition-all shadow-sm"
          >
            <div>
              <div className="w-12 h-12 rounded-xl bg-emerald-500/15 text-emerald-500 flex items-center justify-center mb-5">
                <Wallet className="w-6 h-6" />
              </div>
              <span className="text-[11px] font-bold text-emerald-500 uppercase tracking-wider block mb-1">
                Feature 04
              </span>
              <h3 className="text-xl font-bold text-foreground mb-2">
                Know Who Paid. Know Who Owes.
              </h3>
              <p className="text-xs sm:text-sm text-muted-foreground leading-relaxed mb-4">
                Track deposits via Cash, bKash, or Nagad. Instant ledger shows exact credit balance or pending dues.
              </p>

              <div className="p-3 rounded-xl bg-secondary/60 border border-border/40 space-y-2 mb-4">
                <div className="flex items-center justify-between text-xs">
                  <span className="font-semibold text-foreground">Kawser Ahmed</span>
                  <span className="font-bold text-emerald-500 font-mono">+৳750 (Credit)</span>
                </div>
                <div className="flex items-center justify-between text-xs">
                  <span className="font-semibold text-foreground">Zahid Hasan</span>
                  <span className="font-bold text-rose-500 font-mono">-৳425 (Due)</span>
                </div>
              </div>
            </div>

            <ul className="space-y-1.5 pt-2 border-t border-border/40 text-xs text-muted-foreground">
              <li className="flex items-center gap-2">
                <Check className="w-3.5 h-3.5 text-emerald-500" /> Green for credit, Red for due
              </li>
              <li className="flex items-center gap-2">
                <Check className="w-3.5 h-3.5 text-emerald-500" /> Cash & Mobile Financial Services (MFS) logs
              </li>
            </ul>
          </motion.div>

          {/* FEATURE 05 — AUTOMATIC CALCULATION (Interactive Math Widget) */}
          <motion.div
            initial={{ opacity: 0, y: 25 }}
            whileInView={{ opacity: 1, y: 0 }}
            viewport={{ once: true }}
            transition={{ delay: 0.1 }}
            className="rounded-2xl bg-card border border-[#8B3DFF]/40 p-6 sm:p-7 flex flex-col justify-between hover:border-[#8B3DFF] transition-all shadow-[0_0_30px_rgba(139,61,255,0.1)] md:col-span-2 lg:col-span-2"
          >
            <div>
              <div className="flex items-center justify-between mb-4">
                <div className="flex items-center gap-3">
                  <div className="w-12 h-12 rounded-xl bg-[#8B3DFF]/15 text-[#8B3DFF] flex items-center justify-center">
                    <Calculator className="w-6 h-6" />
                  </div>
                  <div>
                    <span className="text-[11px] font-bold text-[#8B3DFF] uppercase tracking-wider block">
                      Feature 05 • Core Formula
                    </span>
                    <h3 className="text-xl sm:text-2xl font-extrabold text-foreground">
                      You Enter the Data. We Do the Math.
                    </h3>
                  </div>
                </div>
                <span className="hidden sm:inline-flex items-center gap-1 text-[11px] font-bold bg-[#8B3DFF]/10 text-[#8B3DFF] px-2.5 py-1 rounded-full">
                  <Sparkles className="w-3 h-3" /> Live Simulator
                </span>
              </div>

              <p className="text-xs sm:text-sm text-muted-foreground leading-relaxed mb-5">
                Every calculation is fully automatic, deterministic, and 100% transparent. Test the live formula below:
              </p>

              {/* Interactive Calculation Simulator Box */}
              <div className="p-4 sm:p-5 rounded-xl bg-secondary/50 border border-border/50 space-y-4 mb-4">
                <div className="grid grid-cols-3 gap-2 sm:gap-4 text-center">
                  <div>
                    <label className="text-[10px] font-bold text-muted-foreground uppercase block mb-1">
                      Your Meals
                    </label>
                    <input
                      type="number"
                      value={calcMeals}
                      onChange={(e) => setCalcMeals(Number(e.target.value) || 0)}
                      className="w-full text-center py-1.5 font-bold text-base bg-background border border-border/60 rounded-lg text-foreground"
                    />
                  </div>
                  <div>
                    <label className="text-[10px] font-bold text-muted-foreground uppercase block mb-1">
                      Meal Rate (৳)
                    </label>
                    <input
                      type="number"
                      value={calcRate}
                      onChange={(e) => setCalcRate(Number(e.target.value) || 0)}
                      className="w-full text-center py-1.5 font-bold text-base bg-background border border-border/60 rounded-lg text-foreground"
                    />
                  </div>
                  <div>
                    <label className="text-[10px] font-bold text-muted-foreground uppercase block mb-1">
                      Your Deposit (৳)
                    </label>
                    <input
                      type="number"
                      value={calcDeposit}
                      onChange={(e) => setCalcDeposit(Number(e.target.value) || 0)}
                      className="w-full text-center py-1.5 font-bold text-base bg-background border border-border/60 rounded-lg text-foreground"
                    />
                  </div>
                </div>

                {/* Mathematical Formula Display */}
                <div className="flex flex-wrap items-center justify-center gap-2 text-xs font-bold pt-2 border-t border-border/40 font-mono">
                  <span className="text-muted-foreground">({calcMeals} meals × ৳{calcRate}) = ৳{calcCost} cost</span>
                  <span className="text-[#8B3DFF]">➔</span>
                  <span className="text-muted-foreground">Deposit ৳{calcDeposit} − ৳{calcCost} =</span>
                  <span className={`px-2 py-0.5 rounded ${calcBalance >= 0 ? "bg-emerald-500/15 text-emerald-500" : "bg-rose-500/15 text-rose-500"}`}>
                    {calcBalance >= 0 ? `+৳${calcBalance}` : `-৳${Math.abs(calcBalance)}`}
                  </span>
                </div>
              </div>
            </div>

            <div className="flex flex-wrap items-center justify-between gap-2 pt-2 border-t border-border/40 text-xs text-muted-foreground">
              <span>Formula: Total Expenses ÷ Total Meals = Meal Rate</span>
              <span className="text-[#8B3DFF] font-semibold">Zero rounding discrepancies</span>
            </div>
          </motion.div>

          {/* FEATURE 06 — ONLINE + OFFLINE */}
          <motion.div
            initial={{ opacity: 0, y: 25 }}
            whileInView={{ opacity: 1, y: 0 }}
            viewport={{ once: true }}
            className="rounded-2xl bg-card border border-border/70 p-6 sm:p-7 flex flex-col justify-between hover:border-cyan-500/40 transition-all shadow-sm"
          >
            <div>
              <div className="w-12 h-12 rounded-xl bg-cyan-500/15 text-cyan-500 flex items-center justify-center mb-5">
                <WifiOff className="w-6 h-6" />
              </div>
              <span className="text-[11px] font-bold text-cyan-500 uppercase tracking-wider block mb-1">
                Feature 06
              </span>
              <h3 className="text-xl font-bold text-foreground mb-2">
                No Internet? No Problem.
              </h3>
              <p className="text-xs sm:text-sm text-muted-foreground leading-relaxed mb-4">
                Continue logging your meals even when offline. As soon as you reconnect, data syncs automatically to the cloud.
              </p>

              {/* Sync Pipeline Visual */}
              <div className="p-3 rounded-xl bg-secondary/60 border border-border/40 space-y-1.5 mb-4 text-[11px] font-mono">
                <div className="flex items-center gap-2 text-muted-foreground">
                  <span>📱 Offline</span>
                  <span>➔</span>
                  <span>💾 Local Data</span>
                </div>
                <div className="flex items-center gap-2 text-cyan-500 font-bold">
                  <span>🌐 Connected</span>
                  <span>➔</span>
                  <span>☁️ Auto Cloud Sync</span>
                </div>
              </div>
            </div>

            <ul className="space-y-1.5 pt-2 border-t border-border/40 text-xs text-muted-foreground">
              <li className="flex items-center gap-2">
                <Check className="w-3.5 h-3.5 text-cyan-500" /> Offline meal entries preserved safely
              </li>
              <li className="flex items-center gap-2">
                <Check className="w-3.5 h-3.5 text-cyan-500" /> Instant background synchronization
              </li>
            </ul>
          </motion.div>

          {/* FEATURE 07 — REAL-TIME NOTIFICATIONS */}
          <motion.div
            initial={{ opacity: 0, y: 25 }}
            whileInView={{ opacity: 1, y: 0 }}
            viewport={{ once: true }}
            transition={{ delay: 0.1 }}
            className="rounded-2xl bg-card border border-border/70 p-6 sm:p-7 flex flex-col justify-between hover:border-[#A855F7]/40 transition-all shadow-sm"
          >
            <div>
              <div className="w-12 h-12 rounded-xl bg-[#A855F7]/15 text-[#A855F7] flex items-center justify-center mb-5">
                <Bell className="w-6 h-6" />
              </div>
              <span className="text-[11px] font-bold text-[#A855F7] uppercase tracking-wider block mb-1">
                Feature 07
              </span>
              <h3 className="text-xl font-bold text-foreground mb-2">
                Everyone Stays Updated.
              </h3>
              <p className="text-xs sm:text-sm text-muted-foreground leading-relaxed mb-4">
                Instant push alerts whenever meals change, deposits get approved, or bazar expenses are recorded.
              </p>

              <div className="p-2.5 rounded-xl bg-secondary/60 border border-border/40 space-y-1.5 mb-4 text-[11px]">
                <div className="flex items-center gap-1.5 text-foreground font-semibold">
                  <span className="w-1.5 h-1.5 rounded-full bg-[#8B3DFF]" />
                  <span>Kawser updated Lunch from 1.0 ➔ 1.5</span>
                </div>
                <div className="flex items-center gap-1.5 text-foreground font-semibold">
                  <span className="w-1.5 h-1.5 rounded-full bg-emerald-500" />
                  <span>Tanvir deposited ৳2,000</span>
                </div>
              </div>
            </div>

            <ul className="space-y-1.5 pt-2 border-t border-border/40 text-xs text-muted-foreground">
              <li className="flex items-center gap-2">
                <Check className="w-3.5 h-3.5 text-[#A855F7]" /> Push notifications for all major mess events
              </li>
              <li className="flex items-center gap-2">
                <Check className="w-3.5 h-3.5 text-[#A855F7]" /> Real-time Firebase Cloud Messaging
              </li>
            </ul>
          </motion.div>

          {/* FEATURE 08 — MONTHLY REPORT */}
          <motion.div
            initial={{ opacity: 0, y: 25 }}
            whileInView={{ opacity: 1, y: 0 }}
            viewport={{ once: true }}
            transition={{ delay: 0.2 }}
            className="rounded-2xl bg-card border border-border/70 p-6 sm:p-7 flex flex-col justify-between hover:border-emerald-500/40 transition-all shadow-sm"
          >
            <div>
              <div className="w-12 h-12 rounded-xl bg-emerald-500/15 text-emerald-500 flex items-center justify-center mb-5">
                <FileText className="w-6 h-6" />
              </div>
              <span className="text-[11px] font-bold text-emerald-500 uppercase tracking-wider block mb-1">
                Feature 08
              </span>
              <h3 className="text-xl font-bold text-foreground mb-2">
                Your Entire Month. One Report.
              </h3>
              <p className="text-xs sm:text-sm text-muted-foreground leading-relaxed mb-4">
                Export complete monthly balance sheets into clean, shareable PDF reports with one single click.
              </p>

              <div className="p-3 rounded-xl bg-secondary/60 border border-border/40 flex items-center justify-between mb-4">
                <div className="flex items-center gap-2">
                  <FileText className="w-5 h-5 text-emerald-500" />
                  <div>
                    <span className="text-xs font-bold text-foreground block">
                      August_2026_Report.pdf
                    </span>
                    <span className="text-[10px] text-muted-foreground">
                      Full mess ledger & meal rate
                    </span>
                  </div>
                </div>
                <span className="p-1.5 rounded-lg bg-emerald-500/15 text-emerald-600 dark:text-emerald-400">
                  <Download className="w-4 h-4" />
                </span>
              </div>
            </div>

            <ul className="space-y-1.5 pt-2 border-t border-border/40 text-xs text-muted-foreground">
              <li className="flex items-center gap-2">
                <Check className="w-3.5 h-3.5 text-emerald-500" /> Breakdown of meals, bazar & fixed bills
              </li>
              <li className="flex items-center gap-2">
                <Check className="w-3.5 h-3.5 text-emerald-500" /> One-click share to WhatsApp group
              </li>
            </ul>
          </motion.div>
        </div>
      </div>
    </section>
  );
}
