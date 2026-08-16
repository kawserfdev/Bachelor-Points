"use client";

import { useState } from "react";
import { motion, AnimatePresence } from "framer-motion";
import {
  LayoutDashboard,
  Utensils,
  Receipt,
  FileSpreadsheet,
  Settings,
  Calendar,
  Lock,
  Plus,
  Download,
} from "lucide-react";

export function AppScreenshots() {
  const [activeTab, setActiveTab] = useState<
    "overview" | "meals" | "expenses" | "reports" | "manager"
  >("overview");

  const tabs = [
    { id: "overview", label: "Dashboard", icon: LayoutDashboard },
    { id: "meals", label: "Meal Entry", icon: Utensils },
    { id: "expenses", label: "Expenses & Bazar", icon: Receipt },
    { id: "reports", label: "Monthly Reports", icon: FileSpreadsheet },
    { id: "manager", label: "Manager Console", icon: Settings },
  ] as const;

  return (
    <section id="product-demo" className="py-20 lg:py-32 relative">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        {/* Section Header */}
        <div className="text-center max-w-3xl mx-auto mb-12 sm:mb-16">
          <motion.span
            initial={{ opacity: 0, y: 10 }}
            whileInView={{ opacity: 1, y: 0 }}
            viewport={{ once: true }}
            className="text-xs font-bold uppercase tracking-widest text-[#8B3DFF] bg-[#8B3DFF]/10 px-3.5 py-1.5 rounded-full border border-[#8B3DFF]/20"
          >
            Product Walkthrough
          </motion.span>
          <motion.h2
            initial={{ opacity: 0, y: 15 }}
            whileInView={{ opacity: 1, y: 0 }}
            viewport={{ once: true }}
            transition={{ delay: 0.05 }}
            className="text-3xl sm:text-4xl lg:text-5xl font-extrabold tracking-tight mt-4 mb-4"
          >
            See BachelorPoints in Action.
          </motion.h2>
          <motion.p
            initial={{ opacity: 0, y: 15 }}
            whileInView={{ opacity: 1, y: 0 }}
            viewport={{ once: true }}
            transition={{ delay: 0.1 }}
            className="text-muted-foreground text-base sm:text-lg leading-relaxed font-normal"
          >
            A high-performance interface designed with zero friction for daily bachelor mess routines.
          </motion.p>
        </div>

        {/* Interactive Tab Selectors */}
        <div className="flex justify-center mb-10 overflow-x-auto pb-2 scrollbar-none">
          <div className="inline-flex p-1.5 rounded-2xl bg-secondary/80 border border-border/60 gap-1.5 backdrop-blur-md">
            {tabs.map((tab) => {
              const Icon = tab.icon;
              const isActive = activeTab === tab.id;
              return (
                <button
                  key={tab.id}
                  onClick={() => setActiveTab(tab.id)}
                  className={`flex items-center gap-2 px-4 sm:px-5 py-2.5 rounded-xl text-xs sm:text-sm font-semibold transition-all cursor-pointer whitespace-nowrap ${
                    isActive
                      ? "bg-gradient-to-r from-[#8B3DFF] to-[#A855F7] text-white shadow-md shadow-[#8B3DFF]/20"
                      : "text-muted-foreground hover:text-foreground hover:bg-secondary"
                  }`}
                >
                  <Icon className="w-4 h-4" />
                  <span>{tab.label}</span>
                </button>
              );
            })}
          </div>
        </div>

        {/* Tab Content Display */}
        <div className="max-w-5xl mx-auto">
          <div className="rounded-2xl sm:rounded-3xl border border-border/80 bg-card p-1 sm:p-2.5 shadow-[0_20px_60px_rgba(0,0,0,0.3)]">
            {/* Top Browser Bar */}
            <div className="h-10 border-b border-border/50 rounded-t-xl sm:rounded-t-2xl flex items-center justify-between px-4 bg-muted/40 text-xs text-muted-foreground">
              <div className="flex gap-2">
                <div className="w-2.5 h-2.5 rounded-full bg-rose-500/70" />
                <div className="w-2.5 h-2.5 rounded-full bg-amber-500/70" />
                <div className="w-2.5 h-2.5 rounded-full bg-emerald-500/70" />
              </div>
              <div className="font-mono text-[11px] bg-background/80 px-3 py-0.5 rounded-md border border-border/40">
                bachelorpoints.com/{activeTab}
              </div>
              <span className="text-[10px] text-emerald-500 font-bold">● Active Session</span>
            </div>

            {/* Interactive Screen Preview */}
            <div className="p-4 sm:p-7 min-h-[380px] sm:min-h-[440px] flex flex-col justify-center">
              <AnimatePresence mode="wait">
                {activeTab === "overview" && (
                  <motion.div
                    key="overview"
                    initial={{ opacity: 0, y: 10 }}
                    animate={{ opacity: 1, y: 0 }}
                    exit={{ opacity: 0, y: -10 }}
                    transition={{ duration: 0.2 }}
                    className="space-y-6"
                  >
                    <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-2 pb-3 border-b border-border/50">
                      <div>
                        <h3 className="text-lg font-bold text-foreground">
                          August 2026 — Mess Overview
                        </h3>
                        <p className="text-xs text-muted-foreground">
                          10 Active Members • 245.5 Total Meals • Live Rate ৳45.20
                        </p>
                      </div>
                      <span className="text-xs font-bold text-[#8B3DFF] bg-[#8B3DFF]/10 px-3 py-1 rounded-lg self-start sm:self-auto">
                        Total Mess Fund: ৳12,450
                      </span>
                    </div>

                    <div className="grid grid-cols-2 sm:grid-cols-4 gap-3">
                      <div className="p-3.5 rounded-xl bg-secondary/50 border border-border/50">
                        <span className="text-[10px] font-bold text-muted-foreground uppercase">Today&apos;s Meals</span>
                        <p className="text-xl font-extrabold text-foreground mt-1">16.5</p>
                        <span className="text-[10px] text-emerald-500 font-semibold">9 members active</span>
                      </div>
                      <div className="p-3.5 rounded-xl bg-secondary/50 border border-border/50">
                        <span className="text-[10px] font-bold text-muted-foreground uppercase">Today&apos;s Bazar</span>
                        <p className="text-xl font-extrabold text-rose-500 mt-1">৳1,450</p>
                        <span className="text-[10px] text-muted-foreground">By Zahid Hasan</span>
                      </div>
                      <div className="p-3.5 rounded-xl bg-secondary/50 border border-border/50">
                        <span className="text-[10px] font-bold text-muted-foreground uppercase">Tomorrow&apos;s Duty</span>
                        <p className="text-xl font-extrabold text-amber-500 mt-1">Kawser</p>
                        <span className="text-[10px] text-muted-foreground">8:00 AM alert</span>
                      </div>
                      <div className="p-3.5 rounded-xl bg-secondary/50 border border-border/50">
                        <span className="text-[10px] font-bold text-muted-foreground uppercase">Pending Approvals</span>
                        <p className="text-xl font-extrabold text-[#8B3DFF] mt-1">2</p>
                        <span className="text-[10px] text-muted-foreground">1 deposit, 1 expense</span>
                      </div>
                    </div>

                    <div className="p-4 rounded-xl bg-secondary/30 border border-border/50 space-y-2">
                      <span className="text-xs font-bold text-foreground">Recent Mess Updates</span>
                      <div className="space-y-1.5 text-xs text-muted-foreground">
                        <p className="flex items-center justify-between">
                          <span>🍛 Arif updated Dinner portion to 1.5</span>
                          <span className="font-mono text-[10px]">10 mins ago</span>
                        </p>
                        <p className="flex items-center justify-between">
                          <span>💰 Manager approved Tanvir&apos;s ৳2,000 Bkash deposit</span>
                          <span className="font-mono text-[10px]">45 mins ago</span>
                        </p>
                      </div>
                    </div>
                  </motion.div>
                )}

                {activeTab === "meals" && (
                  <motion.div
                    key="meals"
                    initial={{ opacity: 0, y: 10 }}
                    animate={{ opacity: 1, y: 0 }}
                    exit={{ opacity: 0, y: -10 }}
                    transition={{ duration: 0.2 }}
                    className="space-y-5"
                  >
                    <div className="flex items-center justify-between pb-3 border-b border-border/50">
                      <div>
                        <h3 className="text-base font-bold text-foreground flex items-center gap-2">
                          <Calendar className="w-4 h-4 text-[#8B3DFF]" /> Daily Meal Ledger — Today
                        </h3>
                        <p className="text-xs text-muted-foreground">
                          Cutoff time: 10:00 PM (Auto-locks on schedule)
                        </p>
                      </div>
                      <button className="flex items-center gap-1 text-xs font-bold bg-[#8B3DFF] text-white px-3 py-1.5 rounded-lg shadow-sm">
                        <Lock className="w-3.5 h-3.5" /> Lock Today&apos;s Ledger
                      </button>
                    </div>

                    <div className="space-y-2.5">
                      {[
                        { name: "Kawser Ahmed", breakfast: "0.5", lunch: "1.0", dinner: "1.0", total: "2.5", isManager: true },
                        { name: "Tanvir Islam", breakfast: "1.0", lunch: "1.0", dinner: "1.0", total: "3.0", isManager: false },
                        { name: "Zahid Hasan", breakfast: "0.0", lunch: "1.0", dinner: "1.5", total: "2.5", isManager: false },
                        { name: "Arif Rahman", breakfast: "0.5", lunch: "1.0", dinner: "0.0", total: "1.5", isManager: false },
                      ].map((m, idx) => (
                        <div
                          key={idx}
                          className="p-3 rounded-xl bg-secondary/40 border border-border/50 flex flex-col sm:flex-row sm:items-center justify-between gap-3 text-xs"
                        >
                          <div className="flex items-center gap-2.5">
                            <span className="w-7 h-7 rounded-lg bg-[#8B3DFF]/15 text-[#8B3DFF] flex items-center justify-center font-bold">
                              {m.name[0]}
                            </span>
                            <div>
                              <span className="font-bold text-foreground block">{m.name}</span>
                              {m.isManager && <span className="text-[10px] text-[#8B3DFF] font-semibold">Mess Manager</span>}
                            </div>
                          </div>

                          <div className="flex items-center gap-3">
                            <div className="flex items-center gap-1.5 text-muted-foreground">
                              <span>B: <strong className="text-foreground">{m.breakfast}</strong></span>
                              <span>•</span>
                              <span>L: <strong className="text-foreground">{m.lunch}</strong></span>
                              <span>•</span>
                              <span>D: <strong className="text-foreground">{m.dinner}</strong></span>
                            </div>
                            <span className="px-2.5 py-1 rounded-md bg-[#8B3DFF]/15 text-[#8B3DFF] font-bold">
                              {m.total} Meals
                            </span>
                          </div>
                        </div>
                      ))}
                    </div>
                  </motion.div>
                )}

                {activeTab === "expenses" && (
                  <motion.div
                    key="expenses"
                    initial={{ opacity: 0, y: 10 }}
                    animate={{ opacity: 1, y: 0 }}
                    exit={{ opacity: 0, y: -10 }}
                    transition={{ duration: 0.2 }}
                    className="space-y-5"
                  >
                    <div className="flex items-center justify-between pb-3 border-b border-border/50">
                      <div>
                        <h3 className="text-base font-bold text-foreground flex items-center gap-2">
                          <Receipt className="w-4 h-4 text-rose-500" /> Bazar & Shared Expenses
                        </h3>
                        <p className="text-xs text-muted-foreground">
                          All bazar entries require manager approval before entering the ledger
                        </p>
                      </div>
                      <button className="flex items-center gap-1 text-xs font-bold bg-rose-500 text-white px-3 py-1.5 rounded-lg shadow-sm">
                        <Plus className="w-3.5 h-3.5" /> Record Bazar
                      </button>
                    </div>

                    <div className="space-y-2.5">
                      {[
                        { item: "Beef, Rice & Mustard Oil", by: "Zahid Hasan", cat: "Bazar", amount: "৳2,450", status: "Approved" },
                        { item: "High-speed WiFi Bill (August)", by: "Arif Rahman", cat: "Utilities", amount: "৳1,200", status: "Approved" },
                        { item: "Kitchen spices, Garlic & Ginger", by: "Kawser Ahmed", cat: "Bazar", amount: "৳680", status: "Pending Review" },
                      ].map((exp, idx) => (
                        <div
                          key={idx}
                          className="p-3.5 rounded-xl bg-secondary/40 border border-border/50 flex items-center justify-between text-xs"
                        >
                          <div>
                            <span className="font-bold text-foreground block">{exp.item}</span>
                            <span className="text-[11px] text-muted-foreground">
                              Logged by {exp.by} • Category: {exp.cat}
                            </span>
                          </div>
                          <div className="text-right">
                            <span className="text-sm font-extrabold text-rose-500 font-mono block">
                              {exp.amount}
                            </span>
                            <span
                              className={`text-[9px] font-bold px-2 py-0.5 rounded ${
                                exp.status === "Approved"
                                  ? "bg-emerald-500/15 text-emerald-600 dark:text-emerald-400"
                                  : "bg-amber-500/15 text-amber-500"
                              }`}
                            >
                              {exp.status}
                            </span>
                          </div>
                        </div>
                      ))}
                    </div>
                  </motion.div>
                )}

                {activeTab === "reports" && (
                  <motion.div
                    key="reports"
                    initial={{ opacity: 0, y: 10 }}
                    animate={{ opacity: 1, y: 0 }}
                    exit={{ opacity: 0, y: -10 }}
                    transition={{ duration: 0.2 }}
                    className="space-y-5"
                  >
                    <div className="flex items-center justify-between pb-3 border-b border-border/50">
                      <div>
                        <h3 className="text-base font-bold text-foreground flex items-center gap-2">
                          <FileSpreadsheet className="w-4 h-4 text-emerald-500" /> Monthly Audit & PDF Report
                        </h3>
                        <p className="text-xs text-muted-foreground">
                          Export complete mess breakdown with automated formulas
                        </p>
                      </div>
                      <button className="flex items-center gap-1.5 text-xs font-bold bg-emerald-600 hover:bg-emerald-700 text-white px-3.5 py-1.5 rounded-lg shadow-sm">
                        <Download className="w-3.5 h-3.5" /> Download PDF
                      </button>
                    </div>

                    <div className="p-4 rounded-xl bg-secondary/50 border border-border/50 space-y-3">
                      <div className="grid grid-cols-3 gap-2 text-center text-xs">
                        <div>
                          <span className="text-[10px] text-muted-foreground font-semibold">Total Meals</span>
                          <p className="font-extrabold text-base text-foreground mt-0.5">245.5</p>
                        </div>
                        <div>
                          <span className="text-[10px] text-muted-foreground font-semibold">Total Expenses</span>
                          <p className="font-extrabold text-base text-rose-500 mt-0.5">৳35,550</p>
                        </div>
                        <div>
                          <span className="text-[10px] text-muted-foreground font-semibold">Final Meal Rate</span>
                          <p className="font-extrabold text-base text-[#8B3DFF] mt-0.5">৳45.20</p>
                        </div>
                      </div>

                      <div className="pt-2 border-t border-border/40 flex items-center justify-between text-xs font-semibold">
                        <span className="text-muted-foreground">Member settlement status:</span>
                        <span className="text-emerald-500 font-bold">8 Settled • 2 Due</span>
                      </div>
                    </div>
                  </motion.div>
                )}

                {activeTab === "manager" && (
                  <motion.div
                    key="manager"
                    initial={{ opacity: 0, y: 10 }}
                    animate={{ opacity: 1, y: 0 }}
                    exit={{ opacity: 0, y: -10 }}
                    transition={{ duration: 0.2 }}
                    className="space-y-5"
                  >
                    <div className="flex items-center justify-between pb-3 border-b border-border/50">
                      <div>
                        <h3 className="text-base font-bold text-foreground flex items-center gap-2">
                          <Settings className="w-4 h-4 text-[#8B3DFF]" /> Manager Control Center
                        </h3>
                        <p className="text-xs text-muted-foreground">
                          Configure mess rules, manage member roles, and adjust permissions
                        </p>
                      </div>
                      <span className="text-xs font-bold text-emerald-500 bg-emerald-500/10 px-2.5 py-1 rounded-md">
                        Admin Privileges Active
                      </span>
                    </div>

                    <div className="grid sm:grid-cols-2 gap-3 text-xs">
                      <div className="p-3.5 rounded-xl bg-secondary/40 border border-border/50 space-y-1.5">
                        <div className="flex items-center justify-between font-bold text-foreground">
                          <span>Meal Cut-off Time</span>
                          <span className="text-[#8B3DFF]">10:00 PM</span>
                        </div>
                        <p className="text-[11px] text-muted-foreground">
                          Members cannot modify lunch/dinner after this time.
                        </p>
                      </div>

                      <div className="p-3.5 rounded-xl bg-secondary/40 border border-border/50 space-y-1.5">
                        <div className="flex items-center justify-between font-bold text-foreground">
                          <span>Mess Invite Code</span>
                          <span className="font-mono text-[#8B3DFF] bg-background px-2 py-0.5 rounded border border-border/50">
                            #DHAN-742
                          </span>
                        </div>
                        <p className="text-[11px] text-muted-foreground">
                          Share this 6-digit code with flatmates to join instantly.
                        </p>
                      </div>
                    </div>
                  </motion.div>
                )}
              </AnimatePresence>
            </div>
          </div>
        </div>
      </div>
    </section>
  );
}
