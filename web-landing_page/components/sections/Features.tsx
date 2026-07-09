"use client";

import { useState } from "react";
import { motion, AnimatePresence } from "framer-motion";
import {
  Calculator,
  Calendar,
  MessageSquare,
  Bell,
  Users,
  Home,
  TrendingUp,
  ShoppingBag,
  Wallet,
  Inbox,
  KeyRound,
  Sliders,
  CheckCircle2,
  Coins
} from "lucide-react";

const categories = [
  {
    id: "mess-meals",
    name: "মেস ও মিল চালনা",
    description: "মেসের দৈনন্দিন অপারেশন ও মিল ট্র্যাকিংয়ের জন্য অত্যন্ত আধুনিক ও সুসংগঠিত সব ফিচার।",
    features: [
      {
        title: "BachelorPoints",
        subtitle: "👥 মেস গ্রুপ ও সদস্য পরিচালনা",
        description: "ইনস্ট্যান্ট মেস তৈরি করুন এবং মেম্বারদের ইনভাইট কোড দিয়ে অ্যাড করুন। কার কি রোল হবে তা সহজে সেট করুন।",
        icon: Users,
        color: "text-blue-500",
        bg: "bg-blue-500/10",
        badge: "Core",
        bullets: [
          "৬-ডিজিটের ইউনিক ইনভাইট কোড",
          "পেন্ডিং মেম্বার জয়েনিং রিকোয়েস্ট",
          "মেম্বার লিস্টিং ও কন্টাক্ট প্রোফাইল",
          "রোল প্রমোশন ও ডিমোশন (Admin, Manager, Member)"
        ]
      },
      {
        title: "Meal Tracking",
        subtitle: "🍳 মিল ট্র্যাকিং ও ক্যালকুলেশন",
        description: "প্রতিদিনের মিল এবং গেস্ট মিল এন্ট্রি ও ট্র্যাকিংয়ের ঝামেলামুক্ত পদ্ধতি। ম্যানেজার-কনফিগারড কাট-অফ টাইমে লক হয়ে যাবে মিল এন্ট্রি।",
        icon: Calendar,
        color: "text-emerald-500",
        bg: "bg-emerald-500/10",
        badge: "Advanced",
        bullets: [
          "কাস্টমাইজড মিল পোর্শন (0.5, 1.0, 1.5, 2.0 প্লেট)",
          "গেস্ট মিল ও অতিরিক্ত মিল এন্ট্রি",
          "নির্দিষ্ট একটিভ পিরিয়ডের জন্য ডিফল্ট মিল প্ল্যান রিকোয়েস্ট (১ দিন থেকে ১ বছর)",
          "ফ্লেক্সিবল মিল ক্লোজার (এক বা একাধিক দিন মিল অফ করা)",
          "কাট-অফ টাইম গেট (যেমন: রাত ১০:০০ টায় এন্ট্রি লক)"
        ]
      },
      {
        title: "Shopping & Bazar Duty",
        subtitle: "🛒 বাজার ও বাজার ডিউটি শিডিউল",
        description: "বাজারের প্রয়োজনীয় জিনিসের তালিকা তৈরি এবং মেস মেম্বারদের ক্যালেন্ডার অনুযায়ী বাজার ডিউটি অ্যাসাইনমেন্ট।",
        icon: ShoppingBag,
        color: "text-orange-500",
        bg: "bg-orange-500/10",
        bullets: [
          "বাজারের চাহিদার তালিকা ও এপ্রুভাল রিকোয়েস্ট",
          "ক্যালেন্ডার ভিউ দিয়ে বাজার ডিউটি অ্যাসাইনমেন্ট",
          "ডিউটির দিন সকাল ৮:০০ টায় লোকাল পুশ রিমাইন্ডার"
        ]
      },
      {
        title: "Chat Room",
        subtitle: "💬 মেস চ্যাট রুম",
        description: "মেসের মেম্বারদের সাথে তাৎক্ষণিক আলোচনার জন্য ইন-বিল্ট চ্যাট সিস্টেম। রিয়েল-টাইমে আপডেট হয় সবার মেসেজ।",
        icon: MessageSquare,
        color: "text-pink-500",
        bg: "bg-pink-500/10",
        bullets: [
          "রিয়েল-টাইম মেস গ্রুপ চ্যাট",
          "অটো-স্ক্রল ও টাইমস্ট্যাম্পসহ চ্যাট লগ",
          "একটিভ মেম্বারদের ক্যাশিং সুবিধা"
        ]
      }
    ]
  },
  {
    id: "finances",
    name: "আর্থিক হিসাব ও রিপোর্ট",
    description: "ব্যালেন্স শিট, মেস খরচ এবং পিডিএফ রিপোর্ট জেনারেট করার অটোমেটিক সলিউশন।",
    features: [
      {
        title: "Expense Management",
        subtitle: "💰 মেস খরচ ও বাজার লগার",
        description: "মেসের বাজারের খরচ ক্যাটাগরি ও রসিদসহ আপলোড করুন। ম্যানেজার এপ্রুভ করার পর সরাসরি ব্যালেন্স শিটে যুক্ত হবে।",
        icon: TrendingUp,
        color: "text-rose-500",
        bg: "bg-rose-500/10",
        bullets: [
          "ক্যাটাগরি ভিত্তিক খরচ (Shopping, Utilities, Rent, Others)",
          "খরচের রসিদ/মেমো ইমেজ অ্যাটাচমেন্ট",
          "এপ্রুভালের জন্য পেন্ডিং এক্সপেন্স কিউ",
          "ক্যালেন্ডার মাস অনুযায়ী হিস্টোরিকাল খরচ ফিল্টারিং"
        ]
      },
      {
        title: "Balance & Deposits",
        subtitle: "💳 মেম্বার ডিপোজিট ও ব্যালেন্স",
        description: "ক্যাশ বা মোবাইল ব্যাংকিং (Bkash/Nagad/Rocket) এর মাধ্যমে মেম্বারদের টাকা জমার হিসাব ও লাইভ ব্যালেন্স ট্র্যাকিং।",
        icon: Wallet,
        color: "text-cyan-500",
        bg: "bg-cyan-500/10",
        bullets: [
          "ক্যাশ ও মোবাইল ফিনান্সিয়াল সার্ভিস (MFS) ডিপোজিট এন্ট্রি",
          "ম্যানেজার ভেরিফিকেশন ও ক্রেডিট এপ্রুভাল",
          "মোট ডিপোজিট, ব্যক্তিগত জমা ও বাকি টাকার ইনস্ট্যান্ট ক্যালকুলেশন"
        ]
      },
      {
        title: "Approvals & Requests",
        subtitle: "📋 ইউনিফাইড ম্যানেজার ইনবক্স",
        description: "মেস ম্যানেজার এবং এডমিনদের জন্য একটি ড্যাশবোর্ড, যেখান থেকে মেম্বারদের সমস্ত রিকোয়েস্ট যাচাই-বাছাই ও এপ্রুভ করা যায়।",
        icon: Inbox,
        color: "text-purple-500",
        bg: "bg-purple-500/10",
        badge: "Control",
        bullets: [
          "নতুন মেম্বার জয়েন ও মেস এক্সিট রিকোয়েস্ট",
          "খরচ এবং ডিপোজিট ভেরিফিকেশন ও এপ্রুভাল",
          "মিল প্ল্যান পরিবর্তন ও রোল পরিবর্তনের অনুমোদন"
        ]
      },
      {
        title: "Monthly Reports & Analysis",
        subtitle: "📊 মাসিক রিপোর্ট ও ক্যালকুলেশন শীট",
        description: "মাসের শেষে সম্পূর্ণ মেসের অটোমেটিক ক্যালকুলেশন শীট। মিল রেট ও মেম্বার খরচ নিখুঁতভাবে বের করে ডাউনলোড করার সুবিধা।",
        icon: Calculator,
        color: "text-violet-500",
        bg: "bg-violet-500/10",
        bullets: [
          "মিল রেট ক্যালকুলেশন: Meal Rate = Total Expenses / Total Meals",
          "ব্যক্তিগত খরচ ক্যালকুলেশন: Member Cost = Meals × Meal Rate",
          "নেট ব্যালেন্স ক্যালকুলেশন: Net Balance = Total Deposits - Member Cost",
          "পিডিএফ (PDF) এক্সপোর্ট এবং ইনস্ট্যান্ট প্রিন্ট/ডাউনলোড"
        ]
      }
    ]
  },
  {
    id: "marketplace-credits",
    name: "মার্কেটপ্লেস ও ক্রেডিট",
    description: "বাসা ও সিট খোঁজার টু-লেট মার্কেটপ্লেস এবং অ্যাপের ভার্চুয়াল ক্রেডিট ইকোনমি।",
    features: [
      {
        title: "To-Let Property Marketplace",
        subtitle: "🏠 টু-লেট মার্কেটপ্লেস",
        description: "বাড়িওয়ালা ও ভাড়াটিয়াদের জন্য পোর্টাল। বাসা, ফ্ল্যাট, সাবলেট বা মেস সিটের বিজ্ঞাপন দিন সরাসরি অ্যাপে।",
        icon: Home,
        color: "text-indigo-500",
        bg: "bg-indigo-500/10",
        badge: "Marketplace",
        bullets: [
          "লোকেশন (এলাকা/রোড) এবং ম্যাপ কোঅর্ডিনেট সহ প্রপার্টি লিস্টিং",
          "টাইপভিত্তিক বিজ্ঞাপন (Bachelor, Family, Hostel, Mess, Office, Shop)",
          "ভিডিও, ফটো ও ৩৬০ ডিগ্রি ভার্চুয়াল ভিউ সাপোর্ট",
          "ম্যাপ এবং টেক্সট ভিত্তিক সার্চ সুবিধা",
          "ভাড়াটিয়াদের জন্য Need-Based রিকোয়েস্ট পোস্ট",
          "টু-লেট চ্যাট (ভাড়াটিয়া ও মালিকের মধ্যে স্বাধীন কথোপকথন)",
          "KYC ভেরিফিকেশন ব্যাজ (NID, ইউটিলিটি বিল ও লাইসেন্স ভেরিফিকেশন)"
        ]
      },
      {
        title: "Credits System",
        subtitle: "🪙 ক্রেডিট ও বুস্টিং সিস্টেম",
        description: "অ্যাপের ভেতর ভার্চুয়াল ক্রেডিট ইকোনমি। প্রপার্টির কন্টাক্ট ইনফো আনলক এবং বিজ্ঞাপনের বুস্টিং করার জন্য ব্যালেন্স ব্যবহার করুন।",
        icon: Coins,
        color: "text-amber-500",
        bg: "bg-amber-500/10",
        bullets: [
          "বিজ্ঞাপনদাতার কন্টাক্ট আনলক: ৫ ক্রেডিট | ঠিকানা আনলক: ১০ ক্রেডিট",
          "প্রপার্টি পোস্ট ক্রিয়েট: ২০ ক্রেডিট | প্রপার্টি বুস্টিং: ৫০ ক্রেডিট",
          "রিয়েল-টাইম ক্রেডিট ট্রানজেকশন লেজার ও রেফারেল ইনকাম হিস্ট্রি",
          "রেফারেল কমিশন ও উইথড্রয়াল ট্র্যাকিং সিস্টেম"
        ]
      }
    ]
  },
  {
    id: "security-alerts",
    name: "নিরাপত্তা ও নোটিফিকেশন",
    description: "নিরাপদ লগইন, কাস্টম সেটিংস এবং রিয়েল-টাইম পুশ এলার্ট সিস্টেম।",
    features: [
      {
        title: "Authentication",
        subtitle: "🔑 ওয়ান-ক্লিক সিকিউর লগইন",
        description: "নিরাপদ রেজিস্ট্রেশন ও লগইন প্রসেস। ইমেইল ভেরিফিকেশন গেট এর মাধ্যমে মেসের ডাটার সর্বোচ্চ নিরাপত্তা নিশ্চিত করা হয়।",
        icon: KeyRound,
        color: "text-teal-500",
        bg: "bg-teal-500/10",
        bullets: [
          "ইমেইল ভেরিফিকেশন গেটসহ ইউজার রেজিস্ট্রেশন",
          "ইমেইল/পাসওয়ার্ড ও গুগল সাইন-ইন (Google Sign-In)",
          "সিকিউর পাসওয়ার্ড রিসেট ফ্লো (Forgot Password)"
        ]
      },
      {
        title: "Profile & Settings",
        subtitle: "👤 প্রোফাইল ও কনফিগারেশন",
        description: "নিজের কন্টাক্ট ইনফো, মেস লিভ রিকোয়েস্ট এবং মেসের কাট-অফ টাইম সহ অ্যাপের ডার্ক ও লাইট থিম পরিবর্তনের সুবিধা।",
        icon: Sliders,
        color: "text-slate-500",
        bg: "bg-slate-500/10",
        bullets: [
          "প্রোফাইল ইমেজ আপলোড, কন্টাক্ট ও প্রোফাইল প্রগ্রেস %",
          "মেস কাট-অফ টাইম কনফিগারেশন (উদা: রাত ১০টা)",
          "মেস থেকে এক্সিট (লিভ) রিকোয়েস্ট",
          "ডার্ক ও লাইট থিম সুইচিং"
        ]
      },
      {
        title: "Notifications & Alerts",
        subtitle: "🔔 ইনস্ট্যান্ট পুশ এলার্ট ও রিমাইন্ডার",
        description: "রিয়েল-টাইম এফসিএম (FCM) পুশ নোটিফিকেশন যা খরচ, ডিপোজিট এবং রোল পরিবর্তনের তাৎক্ষণিক আপডেট মেম্বারদের কাছে পৌঁছে দেয়।",
        icon: Bell,
        color: "text-yellow-500",
        bg: "bg-yellow-500/10",
        bullets: [
          "FCM সার্ভারলেস ব্যাকএন্ড ইন্টিগ্রেশন",
          "খরচ ও ডিপোজিট রিকোয়েস্ট পেন্ডিং ও এপ্রুভাল নোটিফিকেশন",
          "মিল ক্লোজ, প্ল্যান চেঞ্জ এবং রোল চেঞ্জ ইনস্ট্যান্ট অ্যালার্ট",
          "বাজার ডিউটি পুশ নোটিফিকেশন"
        ]
      }
    ]
  }
];

export function Features() {
  const [activeCategory, setActiveCategory] = useState(categories[0].id);

  return (
    <section id="features" className="py-24 relative overflow-hidden bg-background">
      {/* Decorative background glow */}
      <div className="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 w-[500px] h-[500px] bg-primary/5 blur-[120px] rounded-full -z-10" />

      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div className="text-center mb-16">
          <motion.div
            initial={{ opacity: 0, y: 20 }}
            whileInView={{ opacity: 1, y: 0 }}
            viewport={{ once: true }}
            className="inline-flex items-center px-4 py-1.5 rounded-full text-xs font-semibold bg-primary/10 text-primary border border-primary/20 mb-4"
          >
            ফিচার তালিকা ও মডিউলসমূহ
          </motion.div>
          <motion.h2
            initial={{ opacity: 0, y: 20 }}
            whileInView={{ opacity: 1, y: 0 }}
            viewport={{ once: true }}
            transition={{ delay: 0.1 }}
            className="text-3xl md:text-5xl font-black mb-4 tracking-tight"
          >
            সবকিছু এক জায়গায়
          </motion.h2>
          <motion.p
            initial={{ opacity: 0, y: 20 }}
            whileInView={{ opacity: 1, y: 0 }}
            viewport={{ once: true }}
            transition={{ delay: 0.2 }}
            className="text-muted-foreground text-lg max-w-2xl mx-auto"
          >
            মেস ম্যানেজমেন্ট থেকে শুরু করে টু-লেট খোঁজা - একটি অ্যাপেই মেসের সব সমস্যার সমাধান।
          </motion.p>
        </div>

        {/* Interactive Category Tab Selector */}
        <div className="flex flex-wrap justify-center gap-2 mb-12 max-w-4xl mx-auto p-1.5 rounded-[2rem] bg-zinc-100 dark:bg-zinc-900 border border-border/50">
          {categories.map((category) => {
            const isActive = category.id === activeCategory;
            return (
              <button
                key={category.id}
                onClick={() => setActiveCategory(category.id)}
                className={`relative px-6 py-3 rounded-full text-sm font-medium transition-all duration-300 ${isActive
                    ? "text-primary-foreground font-semibold"
                    : "text-muted-foreground hover:text-foreground"
                  }`}
              >
                {isActive && (
                  <motion.div
                    layoutId="active-tab"
                    className="absolute inset-0 bg-primary rounded-full"
                    style={{ zIndex: 0 }}
                    transition={{ type: "spring", stiffness: 350, damping: 30 }}
                  />
                )}
                <span className="relative z-10">{category.name}</span>
              </button>
            );
          })}
        </div>

        {/* Category Description Area */}
        <AnimatePresence mode="wait">
          <motion.div
            key={activeCategory}
            initial={{ opacity: 0, y: 10 }}
            animate={{ opacity: 1, y: 0 }}
            exit={{ opacity: 0, y: -10 }}
            transition={{ duration: 0.2 }}
            className="text-center mb-16"
          >
            <p className="text-muted-foreground text-base max-w-2xl mx-auto italic">
              &ldquo;{categories.find((c) => c.id === activeCategory)?.description}&rdquo;
            </p>
          </motion.div>
        </AnimatePresence>

        {/* Dynamic Cards Grid */}
        <div className="min-h-[500px]">
          <AnimatePresence mode="wait">
            <motion.div
              key={activeCategory}
              initial={{ opacity: 0, y: 20 }}
              animate={{ opacity: 1, y: 0 }}
              exit={{ opacity: 0, y: -20 }}
              transition={{ duration: 0.3 }}
              className="grid grid-cols-1 md:grid-cols-2 gap-8"
            >
              {categories
                .find((c) => c.id === activeCategory)
                ?.features.map((feature, index) => {
                  const Icon = feature.icon;
                  return (
                    <motion.div
                      key={feature.title}
                      whileHover={{ y: -6 }}
                      className="p-8 rounded-[2rem] border border-border/50 bg-card/40 backdrop-blur-md hover:bg-card hover:border-primary/30 transition-all duration-300 hover:shadow-2xl hover:shadow-primary/5 group relative overflow-hidden flex flex-col justify-between"
                    >
                      {/* Background Glow */}
                      <div className="absolute -right-4 -top-4 w-32 h-32 bg-primary/5 rounded-full blur-3xl group-hover:bg-primary/10 transition-colors duration-500" />

                      <div>
                        {/* Header icon and badge */}
                        <div className="flex justify-between items-start mb-6">
                          <div className={`w-14 h-14 rounded-2xl ${feature.bg} flex items-center justify-center group-hover:scale-110 transition-transform duration-300 relative z-10`}>
                            <Icon className={`w-7 h-7 ${feature.color}`} />
                          </div>
                          {feature.badge && (
                            <span className="px-3 py-1 rounded-full text-xs font-semibold bg-primary/15 text-primary border border-primary/20">
                              {feature.badge}
                            </span>
                          )}
                        </div>

                        <span className="text-xs font-semibold text-primary/80 uppercase tracking-wider block mb-2">{feature.subtitle}</span>
                        <h3 className="text-2xl font-black mb-3 relative z-10 group-hover:text-primary transition-colors duration-300">{feature.title}</h3>
                        <p className="text-muted-foreground leading-relaxed mb-6 text-sm">
                          {feature.description}
                        </p>
                      </div>

                      {/* Feature Bullet Points Checklist */}
                      <ul className="space-y-3 mt-auto pt-6 border-t border-border/40 relative z-10">
                        {feature.bullets.map((bullet, idx) => (
                          <li key={idx} className="flex items-start gap-2.5 text-sm text-foreground/80">
                            <CheckCircle2 className="w-4 h-4 text-emerald-500 shrink-0 mt-0.5" />
                            <span>{bullet}</span>
                          </li>
                        ))}
                      </ul>
                    </motion.div>
                  );
                })}
            </motion.div>
          </AnimatePresence>
        </div>
      </div>
    </section>
  );
}
