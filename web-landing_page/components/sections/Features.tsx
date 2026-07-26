"use client";

import { useState } from "react";
import { motion, AnimatePresence } from "framer-motion";
import {
  Users,
  Calendar,
  ShoppingBag,
  MessageSquare,
  TrendingUp,
  Wallet,
  Inbox,
  Calculator,
  Home,
  Coins,
  KeyRound,
  Sliders,
  Bell,
  Check,
} from "lucide-react";

const categories = [
  {
    id: "mess-meals",
    label: "Mess & Meals",
    description: "Daily operations and meal tracking for your mess.",
    features: [
      {
        title: "Mess Groups",
        icon: Users,
        color: "text-primary",
        bg: "bg-primary/8",
        description: "Create a mess group and invite members with a unique 6-digit code. Set roles, manage members, and handle join requests.",
        bullets: ["Unique invite codes", "Join request approval", "Role management (Admin, Manager, Member)"],
      },
      {
        title: "Meal Tracking",
        icon: Calendar,
        color: "text-emerald-600 dark:text-emerald-400",
        bg: "bg-emerald-500/8",
        description: "Track daily meals with customizable portions. Guest meals, flexible closures, and auto-lock at cut-off time.",
        bullets: ["Custom portions (0.5 to 2.0 plates)", "Guest meal entries", "Cut-off time auto-lock"],
      },
      {
        title: "Shopping & Bazar",
        icon: ShoppingBag,
        color: "text-orange-600 dark:text-orange-400",
        bg: "bg-orange-500/8",
        description: "Create bazar lists, assign duty on a calendar, and get push reminders on duty day at 8 AM.",
        bullets: ["Bazar list with approvals", "Calendar-based duty assignment", "Push reminders"],
      },
      {
        title: "Chat Room",
        icon: MessageSquare,
        color: "text-pink-600 dark:text-pink-400",
        bg: "bg-pink-500/8",
        description: "Built-in real-time group chat. Discuss mess matters without switching to another app.",
        bullets: ["Real-time messaging", "Timestamp logs", "Active member presence"],
      },
    ],
  },
  {
    id: "finances",
    label: "Finances",
    description: "Balance sheets, expenses, and automatic PDF reports.",
    features: [
      {
        title: "Expense Logger",
        icon: TrendingUp,
        color: "text-rose-600 dark:text-rose-400",
        bg: "bg-rose-500/8",
        description: "Log bazar expenses with receipts. Categorize as Shopping, Rent, Utilities, or Others. Manager approval before balance sheet update.",
        bullets: ["Receipt image attachments", "Category-based tracking", "Approval queue"],
      },
      {
        title: "Deposits & Balance",
        icon: Wallet,
        color: "text-cyan-600 dark:text-cyan-400",
        bg: "bg-cyan-500/8",
        description: "Track deposits via cash or mobile banking (Bkash, Nagad, Rocket). Manager verification and instant balance calculation.",
        bullets: ["MFS and cash deposit log", "Manager verification", "Instant balance view"],
      },
      {
        title: "Manager Inbox",
        icon: Inbox,
        color: "text-violet-600 dark:text-violet-400",
        bg: "bg-violet-500/8",
        description: "A unified dashboard for managers to approve expenses, deposits, join requests, and role changes.",
        bullets: ["Join & exit requests", "Expense & deposit approvals", "Role change permissions"],
      },
      {
        title: "Monthly Reports",
        icon: Calculator,
        color: "text-primary",
        bg: "bg-primary/8",
        description: "Auto-calculate meal rate, per-member cost, and generate a clean PDF report for transparency.",
        bullets: ["Meal rate formula built-in", "Per-member cost breakdown", "PDF export & share"],
      },
    ],
  },
  {
    id: "marketplace",
    label: "Marketplace",
    description: "To-let listings and in-app virtual credit economy.",
    features: [
      {
        title: "To-Let Listings",
        icon: Home,
        color: "text-indigo-600 dark:text-indigo-400",
        bg: "bg-indigo-500/8",
        description: "Post and discover bachelor flats, sublets, and mess seats. Location maps, video tours, and KYC-verified badges.",
        bullets: ["Map-based listings", "Photo & video support", "KYC verification badges"],
      },
      {
        title: "Credits System",
        icon: Coins,
        color: "text-amber-600 dark:text-amber-400",
        bg: "bg-amber-500/8",
        description: "Virtual credits to unlock contact info, boost listings, and create property posts. Referral income tracking.",
        bullets: ["Contact unlock: 5 credits", "Boost listing: 50 credits", "Referral income ledger"],
      },
    ],
  },
  {
    id: "security",
    label: "Security",
    description: "Secure login, custom settings, and real-time push alerts.",
    features: [
      {
        title: "Secure Auth",
        icon: KeyRound,
        color: "text-teal-600 dark:text-teal-400",
        bg: "bg-teal-500/8",
        description: "Email verification gate, Google Sign-In, and secure password reset flow.",
        bullets: ["Email verification gate", "Google Sign-In", "Forgot password flow"],
      },
      {
        title: "Profile & Settings",
        icon: Sliders,
        color: "text-slate-600 dark:text-slate-400",
        bg: "bg-slate-500/8",
        description: "Update profile, configure cut-off time, leave request, and toggle dark/light theme.",
        bullets: ["Profile & contact info", "Cut-off time config", "Dark & light theme"],
      },
      {
        title: "Push Notifications",
        icon: Bell,
        color: "text-yellow-600 dark:text-yellow-400",
        bg: "bg-yellow-500/8",
        description: "FCM-powered real-time notifications for expenses, deposits, meal closures, and bazar duty alerts.",
        bullets: ["FCM serverless integration", "Expense & deposit alerts", "Bazar duty push reminders"],
      },
    ],
  },
];

export function Features() {
  const [activeCategory, setActiveCategory] = useState(categories[0].id);
  const current = categories.find((c) => c.id === activeCategory)!;

  return (
    <section id="features" className="py-20 lg:py-28 relative">
      <div className="max-w-6xl mx-auto px-5 sm:px-8">
        {/* Section header */}
        <div className="max-w-2xl mb-10">
          <motion.span
            initial={{ opacity: 0, y: 10 }}
            whileInView={{ opacity: 1, y: 0 }}
            viewport={{ once: true }}
            className="text-[11px] font-bold uppercase tracking-widest text-primary"
          >
            Features
          </motion.span>
          <motion.h2
            initial={{ opacity: 0, y: 15 }}
            whileInView={{ opacity: 1, y: 0 }}
            viewport={{ once: true }}
            transition={{ delay: 0.05 }}
            className="text-3xl sm:text-4xl font-extrabold tracking-[-0.02em] mt-4 mb-3 leading-[1.1]"
          >
            Everything you need,
            <br />
            nothing you don&apos;t.
          </motion.h2>
          <motion.p
            initial={{ opacity: 0, y: 15 }}
            whileInView={{ opacity: 1, y: 0 }}
            viewport={{ once: true }}
            transition={{ delay: 0.1 }}
            className="text-muted-foreground text-[15px] leading-relaxed"
          >
            From daily meal tracking to finding a new seat — one app covers the
            full spectrum of bachelor mess life.
          </motion.p>
        </div>

        {/* Tab selector */}
        <div className="flex gap-1 mb-10 p-1 rounded-lg bg-muted/50 border border-border/40 w-fit">
          {categories.map((cat) => (
            <button
              key={cat.id}
              onClick={() => setActiveCategory(cat.id)}
              className={`relative px-4 py-2 rounded-md text-[13px] font-semibold transition-colors ${
                cat.id === activeCategory
                  ? "text-foreground"
                  : "text-muted-foreground hover:text-foreground"
              }`}
            >
              {cat.id === activeCategory && (
                <motion.div
                  layoutId="feature-tab"
                  className="absolute inset-0 bg-card rounded-md border border-border/40 shadow-sm"
                  transition={{ type: "spring", stiffness: 400, damping: 30 }}
                />
              )}
              <span className="relative z-10">{cat.label}</span>
            </button>
          ))}
        </div>

        {/* Category description */}
        <AnimatePresence mode="wait">
          <motion.p
            key={activeCategory}
            initial={{ opacity: 0, y: 5 }}
            animate={{ opacity: 1, y: 0 }}
            exit={{ opacity: 0, y: -5 }}
            transition={{ duration: 0.15 }}
            className="text-muted-foreground text-[13px] mb-8 font-medium"
          >
            {current.description}
          </motion.p>
        </AnimatePresence>

        {/* Features grid */}
        <AnimatePresence mode="wait">
          <motion.div
            key={activeCategory}
            initial={{ opacity: 0, y: 12 }}
            animate={{ opacity: 1, y: 0 }}
            exit={{ opacity: 0, y: -12 }}
            transition={{ duration: 0.25 }}
            className="grid sm:grid-cols-2 gap-4"
          >
            {current.features.map((feature) => {
              const Icon = feature.icon;
              return (
                <div
                  key={feature.title}
                  className="group p-5 rounded-xl border border-border/40 bg-card hover:border-border/60 transition-all"
                >
                  <div className="flex items-start gap-3.5 mb-3.5">
                    <div
                      className={`w-9 h-9 rounded-lg ${feature.bg} flex items-center justify-center shrink-0`}
                    >
                      <Icon className={`w-4 h-4 ${feature.color}`} />
                    </div>
                    <div>
                      <h3 className="text-[14px] font-bold text-foreground">
                        {feature.title}
                      </h3>
                      <p className="text-[12px] text-muted-foreground leading-relaxed mt-0.5">
                        {feature.description}
                      </p>
                    </div>
                  </div>
                  <ul className="space-y-1.5 ml-[3.25rem]">
                    {feature.bullets.map((bullet, i) => (
                      <li
                        key={i}
                        className="flex items-center gap-2 text-[12px] text-muted-foreground"
                      >
                        <Check className="w-3 h-3 text-primary/60 shrink-0" />
                        {bullet}
                      </li>
                    ))}
                  </ul>
                </div>
              );
            })}
          </motion.div>
        </AnimatePresence>
      </div>
    </section>
  );
}
