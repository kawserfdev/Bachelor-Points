"use client";

import { motion } from "framer-motion";
import { Button } from "@/components/ui/button";
import {
  ArrowRight,
  Play,
  CheckCircle2,
  Bell,
  Wallet,
  ShoppingBag,
  TrendingUp,
  ShieldCheck,
  Smartphone,
  WifiOff,
  Sparkles,
} from "lucide-react";
import { useState } from "react";

export function Hero() {
  const [activeTab, setActiveTab] = useState<"overview" | "balances">("overview");

  return (
    <section className="relative pt-28 sm:pt-36 pb-20 lg:pt-40 lg:pb-32 overflow-hidden">
      {/* Background ambient lighting and subtle tech grid */}
      <div className="absolute inset-0 bg-grid-pattern opacity-60 pointer-events-none" />
      <div className="absolute top-1/4 left-1/2 -translate-x-1/2 -translate-y-1/2 w-[600px] sm:w-[900px] h-[400px] sm:h-[600px] bg-gradient-to-b from-[#8B3DFF]/15 via-[#A855F7]/10 to-transparent blur-[140px] rounded-full pointer-events-none" />
      <div className="absolute -top-24 left-10 w-72 h-72 bg-[#A855F7]/10 blur-[100px] rounded-full pointer-events-none" />
      <div className="absolute top-1/2 right-0 w-80 h-80 bg-[#C084FC]/10 blur-[120px] rounded-full pointer-events-none" />

      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 relative">
        {/* Top Hero Badge */}
        <div className="flex justify-center mb-6 sm:mb-8">
          <motion.div
            initial={{ opacity: 0, y: -10 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.5 }}
            className="inline-flex items-center gap-2.5 px-4 py-2 rounded-full bg-secondary/80 border border-[#8B3DFF]/25 shadow-[0_0_20px_rgba(139,61,255,0.15)] backdrop-blur-md"
          >
            <span className="text-base">🇧🇩</span>
            <span className="text-[12px] sm:text-[13px] font-semibold text-foreground">
              Built for Bangladesh&apos;s Bachelor Mess Life
            </span>
            <span className="w-1.5 h-1.5 rounded-full bg-[#8B3DFF] animate-ping" />
          </motion.div>
        </div>

        {/* Hero Headline & Subtitle */}
        <div className="text-center max-w-4xl mx-auto mb-10 sm:mb-12">
          <motion.h1
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.5, delay: 0.1 }}
            className="text-4xl sm:text-6xl lg:text-[4.25rem] font-extrabold tracking-tight leading-[1.08] text-balance mb-6"
          >
            Stop Fighting Over Meal Costs.
            <br />
            <span className="bg-gradient-to-r from-[#8B3DFF] via-[#A855F7] to-[#C084FC] bg-clip-text text-transparent">
              Manage Your Entire Mess in One Place.
            </span>
          </motion.h1>

          <motion.p
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.5, delay: 0.2 }}
            className="text-muted-foreground text-base sm:text-lg lg:text-xl leading-relaxed max-w-2xl mx-auto mb-8 font-normal"
          >
            Track meals, manage bazar, record expenses, monitor deposits and automatically
            calculate member balances — without spreadsheets, notebooks or complicated calculations.
          </motion.p>

          {/* CTAs */}
          <motion.div
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.5, delay: 0.3 }}
            className="flex flex-col sm:flex-row items-center justify-center gap-3.5 mb-10"
          >
            <Button
              asChild
              size="lg"
              className="w-full sm:w-auto rounded-xl px-8 h-12 sm:h-13 text-[15px] font-bold bg-gradient-to-r from-[#8B3DFF] to-[#A855F7] hover:opacity-95 text-white shadow-[0_0_35px_rgba(139,61,255,0.4)] border border-white/15 cursor-pointer transition-all hover:scale-[1.02]"
            >
              <a href="/app/login" className="flex items-center justify-center gap-2">
                <span>Start Managing Your Mess — Free</span>
                <ArrowRight className="w-4 h-4" />
              </a>
            </Button>
            <Button
              asChild
              size="lg"
              variant="outline"
              className="w-full sm:w-auto rounded-xl px-6 h-12 sm:h-13 text-[15px] font-semibold border-border/80 bg-secondary/40 hover:bg-secondary/80 text-foreground cursor-pointer"
            >
              <a href="#product-demo" className="flex items-center justify-center gap-2">
                <Play className="w-4 h-4 text-[#8B3DFF] fill-[#8B3DFF]/20" />
                <span>Explore Features</span>
              </a>
            </Button>
          </motion.div>

          {/* Trust Indicators */}
          <motion.div
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            transition={{ duration: 0.6, delay: 0.4 }}
            className="flex flex-wrap items-center justify-center gap-x-6 gap-y-2.5 text-[12px] sm:text-[13px] text-muted-foreground font-medium"
          >
            <div className="flex items-center gap-1.5">
              <CheckCircle2 className="w-4 h-4 text-emerald-500 shrink-0" />
              <span>No credit card required</span>
            </div>
            <div className="flex items-center gap-1.5">
              <Smartphone className="w-4 h-4 text-[#8B3DFF] shrink-0" />
              <span>Works on mobile & web</span>
            </div>
            <div className="flex items-center gap-1.5">
              <WifiOff className="w-4 h-4 text-amber-500 shrink-0" />
              <span>Online + Offline ready</span>
            </div>
            <div className="flex items-center gap-1.5">
              <Sparkles className="w-4 h-4 text-cyan-500 shrink-0" />
              <span>Automatic calculations</span>
            </div>
          </motion.div>
        </div>

        {/* Hero Visual Mockup Container */}
        <motion.div
          initial={{ opacity: 0, y: 35 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.7, delay: 0.45 }}
          className="relative max-w-5xl mx-auto"
        >
          {/* Subtle Outer Glow & Frame */}
          <div className="relative rounded-2xl sm:rounded-3xl border border-white/10 dark:border-white/10 bg-card p-1 sm:p-2.5 shadow-[0_20px_80px_rgba(0,0,0,0.4)] backdrop-blur-2xl">
            {/* Top Browser Bar */}
            <div className="h-10 sm:h-12 border-b border-border/50 rounded-t-xl sm:rounded-t-2xl flex items-center justify-between px-4 bg-muted/40">
              <div className="flex items-center gap-2">
                <div className="w-3 h-3 rounded-full bg-rose-500/80" />
                <div className="w-3 h-3 rounded-full bg-amber-500/80" />
                <div className="w-3 h-3 rounded-full bg-emerald-500/80" />
              </div>
              <div className="flex items-center gap-2 bg-background/90 px-4 py-1 rounded-lg border border-border/60 text-[11px] sm:text-xs text-muted-foreground font-mono">
                <ShieldCheck className="w-3.5 h-3.5 text-emerald-500" />
                <span>bachelorpoints.com/mess/dhanmondi-32</span>
              </div>
              <div className="flex items-center gap-1">
                <button
                  onClick={() => setActiveTab("overview")}
                  className={`text-[11px] sm:text-xs font-semibold px-2.5 py-1 rounded-md transition-colors ${
                    activeTab === "overview"
                      ? "bg-[#8B3DFF] text-white"
                      : "text-muted-foreground hover:text-foreground"
                  }`}
                >
                  Overview
                </button>
                <button
                  onClick={() => setActiveTab("balances")}
                  className={`text-[11px] sm:text-xs font-semibold px-2.5 py-1 rounded-md transition-colors ${
                    activeTab === "balances"
                      ? "bg-[#8B3DFF] text-white"
                      : "text-muted-foreground hover:text-foreground"
                  }`}
                >
                  Balances (হিসাব)
                </button>
              </div>
            </div>

            {/* Dashboard Inner Screen */}
            <div className="p-4 sm:p-7 space-y-6">
              {/* Header inside Dashboard */}
              <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-3 pb-4 border-b border-border/50">
                <div>
                  <div className="flex items-center gap-2">
                    <h2 className="text-base sm:text-lg font-bold text-foreground">
                      Green House Mess — Dhanmondi 32
                    </h2>
                    <span className="text-[10px] font-bold uppercase tracking-wider bg-emerald-500/15 text-emerald-600 dark:text-emerald-400 px-2 py-0.5 rounded-full">
                      Live Month
                    </span>
                  </div>
                  <p className="text-xs text-muted-foreground mt-0.5">
                    Manager: Kawser Ahmed • 10 Active Members • Cut-off: 10:00 PM
                  </p>
                </div>
                <div className="flex items-center gap-2">
                  <span className="text-xs font-medium text-muted-foreground bg-secondary/80 px-3 py-1.5 rounded-lg border border-border/50">
                    📅 August 2026
                  </span>
                </div>
              </div>

              {/* KPI Metrics Cards */}
              <div className="grid grid-cols-2 lg:grid-cols-4 gap-3 sm:gap-4">
                <div className="p-4 rounded-xl bg-secondary/40 border border-border/60">
                  <div className="flex items-center justify-between text-muted-foreground mb-1.5">
                    <span className="text-[11px] font-semibold uppercase tracking-wider">
                      Total Meals
                    </span>
                    <span className="text-sm">🍛</span>
                  </div>
                  <div className="text-2xl sm:text-3xl font-extrabold text-foreground tracking-tight">
                    245.5
                  </div>
                  <span className="text-[10px] text-emerald-500 font-semibold mt-1 block">
                    +18 meals vs last week
                  </span>
                </div>

                <div className="p-4 rounded-xl bg-secondary/40 border border-border/60">
                  <div className="flex items-center justify-between text-muted-foreground mb-1.5">
                    <span className="text-[11px] font-semibold uppercase tracking-wider">
                      Mess Balance
                    </span>
                    <Wallet className="w-4 h-4 text-[#8B3DFF]" />
                  </div>
                  <div className="text-2xl sm:text-3xl font-extrabold text-emerald-600 dark:text-emerald-400 tracking-tight">
                    ৳12,450
                  </div>
                  <span className="text-[10px] text-muted-foreground font-medium mt-1 block">
                    Deposits: ৳48,000
                  </span>
                </div>

                <div className="p-4 rounded-xl bg-secondary/40 border border-border/60">
                  <div className="flex items-center justify-between text-muted-foreground mb-1.5">
                    <span className="text-[11px] font-semibold uppercase tracking-wider">
                      Current Meal Rate
                    </span>
                    <TrendingUp className="w-4 h-4 text-[#A855F7]" />
                  </div>
                  <div className="text-2xl sm:text-3xl font-extrabold text-[#8B3DFF] tracking-tight">
                    ৳45.20
                  </div>
                  <span className="text-[10px] text-muted-foreground font-medium mt-1 block">
                    Auto-calculated live
                  </span>
                </div>

                <div className="p-4 rounded-xl bg-secondary/40 border border-border/60">
                  <div className="flex items-center justify-between text-muted-foreground mb-1.5">
                    <span className="text-[11px] font-semibold uppercase tracking-wider">
                      Bazar Expenses
                    </span>
                    <ShoppingBag className="w-4 h-4 text-rose-500" />
                  </div>
                  <div className="text-2xl sm:text-3xl font-extrabold text-foreground tracking-tight">
                    ৳35,550
                  </div>
                  <span className="text-[10px] text-muted-foreground font-medium mt-1 block">
                    22 Bazar receipts
                  </span>
                </div>
              </div>

              {/* Conditional Tab Views */}
              {activeTab === "overview" ? (
                <div className="grid lg:grid-cols-12 gap-5">
                  {/* Left Chart View */}
                  <div className="lg:col-span-7 rounded-xl bg-secondary/30 border border-border/50 p-4 sm:p-5">
                    <div className="flex items-center justify-between mb-4">
                      <div>
                        <p className="text-xs font-bold text-foreground">
                          Daily Meal Intake & Bazar Trend
                        </p>
                        <p className="text-[10px] text-muted-foreground">
                          August 01 - August 16, 2026
                        </p>
                      </div>
                      <div className="flex items-center gap-3 text-[10px] font-medium">
                        <span className="flex items-center gap-1.5 text-foreground">
                          <span className="w-2 h-2 rounded-full bg-[#8B3DFF]" />
                          Meals
                        </span>
                        <span className="flex items-center gap-1.5 text-muted-foreground">
                          <span className="w-2 h-2 rounded-full bg-rose-500" />
                          Bazar (৳)
                        </span>
                      </div>
                    </div>

                    {/* SVG Analytics Chart */}
                    <div className="h-36 sm:h-44 w-full relative">
                      <svg
                        className="w-full h-full"
                        viewBox="0 0 500 120"
                        preserveAspectRatio="none"
                      >
                        <defs>
                          <linearGradient id="mealGlow" x1="0" y1="0" x2="0" y2="1">
                            <stop offset="0%" stopColor="#8B3DFF" stopOpacity="0.25" />
                            <stop offset="100%" stopColor="#8B3DFF" stopOpacity="0.0" />
                          </linearGradient>
                        </defs>
                        {/* Grid Guides */}
                        <line x1="0" y1="30" x2="500" y2="30" stroke="currentColor" strokeOpacity="0.06" />
                        <line x1="0" y1="60" x2="500" y2="60" stroke="currentColor" strokeOpacity="0.06" />
                        <line x1="0" y1="90" x2="500" y2="90" stroke="currentColor" strokeOpacity="0.06" />

                        {/* Meal Trend Line */}
                        <path
                          d="M 0,90 Q 50,45 100,55 T 200,35 T 300,70 T 400,25 T 500,40 L 500,120 L 0,120 Z"
                          fill="url(#mealGlow)"
                        />
                        <path
                          d="M 0,90 Q 50,45 100,55 T 200,35 T 300,70 T 400,25 T 500,40"
                          fill="none"
                          stroke="#8B3DFF"
                          strokeWidth="3"
                          strokeLinecap="round"
                        />
                        {/* Bazar Expense Line */}
                        <path
                          d="M 0,105 Q 60,80 120,60 T 240,40 T 360,85 T 480,50"
                          fill="none"
                          stroke="#F43F5E"
                          strokeWidth="2"
                          strokeDasharray="4 4"
                          strokeLinecap="round"
                        />
                      </svg>
                    </div>

                    <div className="flex justify-between text-[10px] text-muted-foreground font-mono mt-2">
                      <span>Aug 01</span>
                      <span>Aug 05</span>
                      <span>Aug 10</span>
                      <span>Aug 15</span>
                      <span>Today</span>
                    </div>
                  </div>

                  {/* Right Live Activity Feed */}
                  <div className="lg:col-span-5 rounded-xl bg-secondary/30 border border-border/50 p-4 sm:p-5">
                    <div className="flex items-center justify-between mb-3 pb-2 border-b border-border/40">
                      <span className="text-xs font-bold text-foreground">
                        Live Mess Feed
                      </span>
                      <span className="text-[10px] font-semibold text-[#8B3DFF] bg-[#8B3DFF]/10 px-2 py-0.5 rounded-full">
                        Real-time
                      </span>
                    </div>
                    <div className="space-y-3">
                      {[
                        {
                          title: "Kawser added 1.0 lunch meal",
                          sub: "Portion locked for 1:30 PM",
                          time: "3 mins ago",
                          badge: "🍛 Meal",
                          color: "bg-[#8B3DFF]/10 text-[#8B3DFF]",
                        },
                        {
                          title: "Zahid recorded Bazar: ৳1,450",
                          sub: "Chicken, Rice & Vegetables",
                          time: "25 mins ago",
                          badge: "🛒 Bazar",
                          color: "bg-rose-500/10 text-rose-500",
                        },
                        {
                          title: "Tanvir deposited ৳3,000 (Bkash)",
                          sub: "Approved by Mess Manager",
                          time: "2 hours ago",
                          badge: "💰 Deposit",
                          color: "bg-emerald-500/10 text-emerald-600 dark:text-emerald-400",
                        },
                        {
                          title: "Bazar Duty Reminder: Arif Rahman",
                          sub: "Scheduled for tomorrow 8:00 AM",
                          time: "4 hours ago",
                          badge: "🔔 Duty",
                          color: "bg-amber-500/10 text-amber-500",
                        },
                      ].map((item, idx) => (
                        <div key={idx} className="flex items-start justify-between gap-2 text-xs">
                          <div>
                            <div className="flex items-center gap-1.5">
                              <span className={`text-[9px] font-bold px-1.5 py-0.2 rounded ${item.color}`}>
                                {item.badge}
                              </span>
                              <span className="font-semibold text-foreground">
                                {item.title}
                              </span>
                            </div>
                            <p className="text-[11px] text-muted-foreground mt-0.5">
                              {item.sub}
                            </p>
                          </div>
                          <span className="text-[10px] text-muted-foreground/70 shrink-0 font-mono">
                            {item.time}
                          </span>
                        </div>
                      ))}
                    </div>
                  </div>
                </div>
              ) : (
                /* Member Balances Table (হিসাব) */
                <div className="rounded-xl bg-secondary/30 border border-border/50 p-4 sm:p-5 overflow-x-auto">
                  <table className="w-full text-left text-xs">
                    <thead>
                      <tr className="border-b border-border/50 text-muted-foreground text-[11px] uppercase tracking-wider font-semibold">
                        <th className="pb-3">Member Name</th>
                        <th className="pb-3">Meals</th>
                        <th className="pb-3">Deposit (জমা)</th>
                        <th className="pb-3">Meal Cost (খরচ)</th>
                        <th className="pb-3 text-right">Balance (হিসাব)</th>
                      </tr>
                    </thead>
                    <tbody className="divide-y divide-border/30">
                      {[
                        { name: "Kawser Ahmed (Manager)", meals: "28.5", deposit: "৳5,000", cost: "৳4,250", balance: "+৳750", isPositive: true },
                        { name: "Tanvir Islam", meals: "32.0", deposit: "৳6,000", cost: "৳4,800", balance: "+৳1,200", isPositive: true },
                        { name: "Zahid Hasan", meals: "26.0", deposit: "৳3,500", cost: "৳3,925", balance: "-৳425", isPositive: false },
                        { name: "Arif Rahman", meals: "24.5", deposit: "৳4,000", cost: "৳3,675", balance: "+৳325", isPositive: true },
                        { name: "Sajid Mahbub", meals: "30.0", deposit: "৳3,000", cost: "৳4,500", balance: "-৳1,500", isPositive: false },
                      ].map((member, i) => (
                        <tr key={i} className="hover:bg-secondary/40 transition-colors">
                          <td className="py-2.5 font-semibold text-foreground flex items-center gap-2">
                            <span className="w-6 h-6 rounded-full bg-[#8B3DFF]/15 text-[#8B3DFF] flex items-center justify-center font-bold text-[10px]">
                              {member.name[0]}
                            </span>
                            {member.name}
                          </td>
                          <td className="py-2.5 font-medium">{member.meals}</td>
                          <td className="py-2.5 font-medium text-foreground">{member.deposit}</td>
                          <td className="py-2.5 font-medium text-muted-foreground">{member.cost}</td>
                          <td className="py-2.5 text-right font-bold font-mono">
                            <span
                              className={`px-2 py-0.5 rounded ${
                                member.isPositive
                                  ? "bg-emerald-500/15 text-emerald-600 dark:text-emerald-400"
                                  : "bg-rose-500/15 text-rose-500"
                              }`}
                            >
                              {member.balance}
                            </span>
                          </td>
                        </tr>
                      ))}
                    </tbody>
                  </table>
                </div>
              )}
            </div>
          </div>

          {/* Floating Live Notification Badges */}
          <div className="absolute -top-4 sm:-top-5 -right-2 sm:-right-4 hidden sm:flex items-center gap-3 bg-card/95 border border-white/15 px-4 py-3 rounded-2xl shadow-[0_10px_30px_rgba(0,0,0,0.3)] backdrop-blur-xl animate-bounce duration-1000">
            <div className="w-9 h-9 rounded-xl bg-emerald-500/15 text-emerald-500 flex items-center justify-center font-bold">
              ৳
            </div>
            <div>
              <p className="text-[10px] text-muted-foreground font-bold uppercase tracking-wider">
                💰 Deposit Added
              </p>
              <p className="text-xs font-extrabold text-foreground">
                ৳2,000 deposit recorded
              </p>
            </div>
          </div>

          <div className="absolute -bottom-4 sm:-bottom-6 -left-2 sm:-left-4 hidden sm:flex items-center gap-3 bg-card/95 border border-white/15 px-4 py-3 rounded-2xl shadow-[0_10px_30px_rgba(0,0,0,0.3)] backdrop-blur-xl">
            <div className="w-9 h-9 rounded-xl bg-[#8B3DFF]/15 text-[#8B3DFF] flex items-center justify-center">
              <Bell className="w-4 h-4" />
            </div>
            <div>
              <p className="text-[10px] text-muted-foreground font-bold uppercase tracking-wider">
                🔔 Meal Updated
              </p>
              <p className="text-xs font-extrabold text-foreground">
                Kawser added 1.0 lunch meal
              </p>
            </div>
          </div>
        </motion.div>
      </div>
    </section>
  );
}
