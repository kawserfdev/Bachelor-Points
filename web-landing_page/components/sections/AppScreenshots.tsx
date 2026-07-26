"use client";

import { motion } from "framer-motion";
import { Check, Plus, Receipt, Download, Calendar, Users, ShoppingBag } from "lucide-react";

const screenshots = [
  {
    title: "Meal Management",
    label: "Module 01",
    description: "Track daily meals with the simplest interface. Custom portions, guest meals, and auto-lock at cut-off time.",
    bullets: [
      "Custom portions from 0.5 to 2.0 plates",
      "Flexible meal closure and editing",
      "Guest meal tracking with cut-off lock",
    ],
    renderPreview: () => (
      <div className="w-full h-full bg-background p-4 flex flex-col font-sans text-[11px] text-foreground">
        <div className="flex items-center justify-between mb-4 border-b border-border/40 pb-2">
          <span className="font-bold flex items-center gap-1.5">
            <Calendar className="w-3.5 h-3.5 text-primary" /> Meal Ledger
          </span>
          <span className="text-[10px] bg-primary/10 text-primary px-2 py-0.5 rounded-md font-bold">
            Today
          </span>
        </div>
        <p className="text-[10px] text-muted-foreground mb-3 font-medium">
          Set default meal or customize per member:
        </p>
        <div className="space-y-2 flex-1 overflow-y-auto">
          {[
            { name: "Arif Rahman", val: "1.5", active: true },
            { name: "Zahid Hasan", val: "1.0", active: true },
            { name: "Tamim Iqbal", val: "0.0", active: false },
            { name: "Mahmudullah", val: "2.0", active: true },
          ].map((m, idx) => (
            <div
              key={idx}
              className={`p-2.5 rounded-lg border flex items-center justify-between ${
                m.active
                  ? "bg-card border-border/50"
                  : "bg-muted/30 border-border/20 opacity-60"
              }`}
            >
              <div className="flex items-center gap-2">
                <div className="w-5 h-5 rounded-full bg-primary/10 flex items-center justify-center font-bold text-[9px] text-primary">
                  {m.name[0]}
                </div>
                <span className="font-semibold">{m.name}</span>
              </div>
              <span
                className={`px-2 py-0.5 rounded text-[10px] font-bold ${
                  m.active
                    ? "bg-primary/10 text-primary"
                    : "bg-muted text-muted-foreground"
                }`}
              >
                {m.val}
              </span>
            </div>
          ))}
        </div>
        <button className="w-full py-2.5 bg-primary text-primary-foreground font-bold rounded-lg mt-3 flex items-center justify-center gap-1 text-[11px]">
          <Check className="w-3.5 h-3.5" /> Lock Meal Entry
        </button>
      </div>
    ),
  },
  {
    title: "Expense Tracker",
    label: "Module 02",
    description: "Log bazar expenses with receipts. Category-based tracking with manager verification for full transparency.",
    bullets: [
      "Receipt and memo image uploads",
      "Category-based expense tracking",
      "Manager approval queue",
    ],
    renderPreview: () => (
      <div className="w-full h-full bg-background p-4 flex flex-col font-sans text-[11px] text-foreground">
        <div className="flex items-center justify-between mb-4 border-b border-border/40 pb-2">
          <span className="font-bold flex items-center gap-1.5">
            <ShoppingBag className="w-3.5 h-3.5 text-rose-500" /> Bazar & Bills
          </span>
          <span className="text-[10px] text-muted-foreground font-medium">July 2026</span>
        </div>
        <div className="grid grid-cols-2 gap-2 mb-3">
          <div className="bg-muted/30 border border-border/30 rounded-lg p-2.5">
            <span className="text-muted-foreground text-[9px] font-medium block">Total Bazar</span>
            <span className="text-lg font-extrabold text-rose-500">৳12,450</span>
          </div>
          <div className="bg-muted/30 border border-border/30 rounded-lg p-2.5">
            <span className="text-muted-foreground text-[9px] font-medium block">Pending</span>
            <span className="text-lg font-extrabold text-amber-500">3</span>
          </div>
        </div>
        <div className="space-y-2 flex-1 overflow-y-auto">
          {[
            { details: "Dal, oil & potatoes", amount: "৳540", by: "Zahid", cat: "Bazar", status: "Approved" },
            { details: "Electricity bill", amount: "৳1,200", by: "Arif", cat: "Utility", status: "Approved" },
            { details: "Maid salary", amount: "৳3,000", by: "Manager", cat: "Other", status: "Pending" },
          ].map((item, idx) => (
            <div key={idx} className="p-2.5 rounded-lg bg-card border border-border/40 flex justify-between items-center">
              <div>
                <span className="font-bold block">{item.details}</span>
                <span className="text-[9px] text-muted-foreground">
                  By: {item.by} &bull; {item.cat}
                </span>
              </div>
              <div className="text-right">
                <span className="font-extrabold block text-rose-500">{item.amount}</span>
                <span
                  className={`text-[8px] font-bold px-1.5 py-0.5 rounded ${
                    item.status === "Approved"
                      ? "bg-emerald-500/10 text-emerald-600"
                      : "bg-amber-500/10 text-amber-600"
                  }`}
                >
                  {item.status}
                </span>
              </div>
            </div>
          ))}
        </div>
        <div className="flex gap-1.5 mt-3">
          <button className="flex-1 py-2 bg-muted/50 text-foreground font-bold rounded-lg flex items-center justify-center gap-1 border border-border/50 text-[10px]">
            <Receipt className="w-3 h-3" /> View Receipts
          </button>
          <button className="py-2 px-3 bg-rose-500 text-white font-bold rounded-lg flex items-center justify-center">
            <Plus className="w-3.5 h-3.5" />
          </button>
        </div>
      </div>
    ),
  },
  {
    title: "Balance Sheet",
    label: "Module 03",
    description: "One-click monthly summary. See who paid, who owes, and download a clean PDF for full transparency.",
    bullets: [
      "Real-time deposit tracking",
      "Automatic meal rate calculation",
      "One-click PDF download & share",
    ],
    renderPreview: () => (
      <div className="w-full h-full bg-background p-4 flex flex-col font-sans text-[11px] text-foreground">
        <div className="flex items-center justify-between mb-4 border-b border-border/40 pb-2">
          <span className="font-bold flex items-center gap-1.5">
            <Users className="w-3.5 h-3.5 text-cyan-500" /> Balance & Reports
          </span>
          <span className="text-[10px] font-extrabold text-cyan-500">Rate: ৳32.50</span>
        </div>
        <div className="bg-cyan-500/5 border border-cyan-500/10 rounded-lg p-2.5 mb-3 flex items-center justify-between">
          <div>
            <span className="text-[9px] text-muted-foreground font-medium block">Total Meals</span>
            <span className="text-sm font-extrabold">420.00</span>
          </div>
          <div className="text-right">
            <span className="text-[9px] text-muted-foreground font-medium block">Total Bazar</span>
            <span className="text-sm font-extrabold text-primary">৳13,650</span>
          </div>
        </div>
        <div className="space-y-2 flex-1 overflow-y-auto">
          {[
            { name: "Arif Rahman", deposit: "৳4,000", cost: "৳3,250", bal: "৳750", state: "Credit" },
            { name: "Zahid Hasan", deposit: "৳2,500", cost: "৳2,925", bal: "-৳425", state: "Due" },
            { name: "Tamim Iqbal", deposit: "৳5,000", cost: "৳3,600", bal: "৳1,400", state: "Credit" },
          ].map((m, idx) => (
            <div key={idx} className="p-2.5 rounded-lg bg-card border border-border/40 flex justify-between items-center text-[10px]">
              <div>
                <span className="font-bold text-foreground block">{m.name}</span>
                <span className="text-muted-foreground text-[8px]">
                  Paid: {m.deposit} &bull; Cost: {m.cost}
                </span>
              </div>
              <div className="text-right">
                <span
                  className={`font-extrabold block ${
                    m.state === "Credit" ? "text-emerald-600" : "text-rose-500"
                  }`}
                >
                  {m.bal}
                </span>
                <span className="text-[8px] text-muted-foreground">{m.state}</span>
              </div>
            </div>
          ))}
        </div>
        <button className="w-full py-2.5 bg-cyan-600 hover:bg-cyan-700 text-white font-bold rounded-lg mt-3 flex items-center justify-center gap-1.5 text-[11px]">
          <Download className="w-3.5 h-3.5" /> Download PDF Report
        </button>
      </div>
    ),
  },
];

export function AppScreenshots() {
  return (
    <section className="py-20 lg:py-28 relative">
      <div className="max-w-6xl mx-auto px-5 sm:px-8">
        {/* Section header */}
        <div className="max-w-2xl mb-16">
          <motion.span
            initial={{ opacity: 0, y: 10 }}
            whileInView={{ opacity: 1, y: 0 }}
            viewport={{ once: true }}
            className="text-[11px] font-bold uppercase tracking-widest text-primary"
          >
            Product Screens
          </motion.span>
          <motion.h2
            initial={{ opacity: 0, y: 15 }}
            whileInView={{ opacity: 1, y: 0 }}
            viewport={{ once: true }}
            transition={{ delay: 0.05 }}
            className="text-3xl sm:text-4xl font-extrabold tracking-[-0.02em] mt-4 mb-3 leading-[1.1]"
          >
            Designed for how
            <br />
            you actually live.
          </motion.h2>
          <motion.p
            initial={{ opacity: 0, y: 15 }}
            whileInView={{ opacity: 1, y: 0 }}
            viewport={{ once: true }}
            transition={{ delay: 0.1 }}
            className="text-muted-foreground text-[15px] leading-relaxed"
          >
            Our mobile and web interfaces are built around the bachelor lifestyle
            — fast, clear, and zero friction.
          </motion.p>
        </div>

        {/* Screenshots */}
        <div className="space-y-24">
          {screenshots.map((item, index) => (
            <motion.div
              key={index}
              initial={{ opacity: 0, y: 30 }}
              whileInView={{ opacity: 1, y: 0 }}
              viewport={{ once: true }}
              transition={{ duration: 0.5 }}
              className={`flex flex-col ${
                index % 2 === 0 ? "lg:flex-row" : "lg:flex-row-reverse"
              } gap-12 lg:gap-16 items-center`}
            >
              {/* Text */}
              <div className="flex-1 space-y-4">
                <span className="text-[11px] font-bold text-primary uppercase tracking-widest">
                  {item.label}
                </span>
                <h3 className="text-2xl sm:text-3xl font-extrabold tracking-[-0.02em]">
                  {item.title}
                </h3>
                <p className="text-muted-foreground text-[14px] leading-relaxed">
                  {item.description}
                </p>
                <ul className="space-y-2.5 pt-1">
                  {item.bullets.map((bullet, i) => (
                    <li key={i} className="flex items-start gap-2.5">
                      <div className="w-4 h-4 rounded-full bg-primary/8 flex items-center justify-center shrink-0 mt-0.5">
                        <Check className="w-2.5 h-2.5 text-primary" />
                      </div>
                      <span className="text-[13px] font-medium text-muted-foreground">
                        {bullet}
                      </span>
                    </li>
                  ))}
                </ul>
              </div>

              {/* Phone mockup */}
              <div className="flex-1 w-full max-w-[320px] mx-auto">
                <div className="relative">
                  {/* Subtle shadow */}
                  <div className="absolute -inset-2 bg-gradient-to-b from-primary/[0.04] to-transparent rounded-3xl blur-lg pointer-events-none" />

                  {/* Phone frame */}
                  <div className="relative mx-auto w-64 sm:w-72 aspect-[9/19.5] rounded-[2.5rem] border-[6px] border-neutral-800 bg-neutral-950 shadow-2xl overflow-hidden p-2.5">
                    {/* Dynamic island */}
                    <div className="absolute top-2 inset-x-0 h-5 flex items-center justify-center z-20 pointer-events-none">
                      <div className="w-16 h-3.5 bg-neutral-800 rounded-full" />
                    </div>

                    {/* Screen */}
                    <div className="w-full h-full rounded-[1.75rem] overflow-hidden border border-neutral-900">
                      {item.renderPreview()}
                    </div>
                  </div>
                </div>
              </div>
            </motion.div>
          ))}
        </div>
      </div>
    </section>
  );
}
