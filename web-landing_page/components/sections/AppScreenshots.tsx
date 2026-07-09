"use client";

import { motion } from "framer-motion";
import Image from "next/image";

const screenshots = [
  {
    title: "Meal Management",
    description: "প্রতিদিনের মিল এন্ট্রি এবং ট্র্যাকিং এর জন্য সবচেয়ে সহজ ইন্টারফেস।",
    src: "/screenshots/meals.png", // Placeholder path
    bullets: [
      "কাস্টমাইজড মিল পোর্শন এন্ট্রি (০.৫, ১.০, ১.৫, ২.০ প্লেট)",
      "মেস মেম্বারদের জন্য ফ্লেক্সিবল মিল ক্লোজার ও এডিট",
      "গেস্ট মিল ট্র্যাকিং এবং কাট-অফ টাইমে অটো-লক সিস্টেম"
    ]
  },
  {
    title: "Expense Tracker",
    description: "বাজার খরচ এবং মেসের কমন খরচের হিসাব রাখুন নির্ভুলভাবে।",
    src: "/screenshots/expenses.png",
    bullets: [
      "বাজার খরচের সাথে রসিদ বা মেমোর ছবি আপলোড",
      "ক্যাটাগরি ভিত্তিক খরচ ট্র্যাকিং (Shopping, Utilities, Rent, Others)",
      "স্বচ্ছতা নিশ্চিত করতে ম্যানেজার ভেরিফিকেশন ও এপ্রুভাল কিউ"
    ]
  },
  {
    title: "Automatic Balance",
    description: "মাসের শেষে কার কত ব্যালেন্স তা জাস্ট এক ক্লিকে দেখে নিন।",
    src: "/screenshots/balance.png",
    bullets: [
      "রিয়েল-টাইম ডিপোজিট এন্ট্রি এবং লাইভ ব্যালেন্স ট্র্যাকিং",
      "অটোমেটিক মিল রেট, সদস্য ভিত্তিক খরচ ও বাকি ব্যালেন্স হিসাব",
      "স্বচ্ছতার জন্য এক ক্লিকে PDF শিট ডাউনলোড ও শেয়ার"
    ]
  },
];

export function AppScreenshots() {
  return (
    <section className="py-24 bg-white dark:bg-black overflow-hidden">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div className="text-center mb-20">
          <motion.h2
            initial={{ opacity: 0, y: 20 }}
            whileInView={{ opacity: 1, y: 0 }}
            viewport={{ once: true }}
            className="text-3xl md:text-5xl font-bold mb-4"
          >
            Experience the Future of BachelorPoints
          </motion.h2>
          <p className="text-muted-foreground text-lg max-w-2xl mx-auto">
            আমাদের মোবাইল এবং ওয়েব ইন্টারফেস ডিজাইন করা হয়েছে ব্যাসেলরদের লাইফস্টাইল মাথায় রেখে।
          </p>
        </div>

        <div className="space-y-32">
          {screenshots.map((item, index) => (
            <motion.div
              key={index}
              initial={{ opacity: 0, y: 50 }}
              whileInView={{ opacity: 1, y: 0 }}
              viewport={{ once: true }}
              transition={{ duration: 0.8 }}
              className={`flex flex-col ${index % 2 === 0 ? "lg:flex-row" : "lg:flex-row-reverse"
                } gap-12 items-center`}
            >
              {/* Text Side */}
              <div className="flex-1 space-y-6">
                <h3 className="text-2xl md:text-4xl font-bold">{item.title}</h3>
                <p className="text-muted-foreground text-lg leading-relaxed">
                  {item.description}
                </p>
                <ul className="space-y-4">
                  {item.bullets.map((bullet, i) => (
                    <li key={i} className="flex items-center gap-3">
                      <div className="w-6 h-6 rounded-full bg-primary/10 flex items-center justify-center">
                        <div className="w-2 h-2 rounded-full bg-primary" />
                      </div>
                      <span className="text-foreground/80">{bullet}</span>
                    </li>
                  ))}
                </ul>
              </div>

              {/* Screenshot Mockup Side */}
              <div className="flex-1 w-full max-w-2xl">
                <div className="relative group">
                  <div className="absolute -inset-4 bg-gradient-to-r from-primary/20 to-purple-500/20 blur-2xl opacity-50 group-hover:opacity-75 transition-opacity" />
                  <div className="relative rounded-2xl border border-border/50 bg-card overflow-hidden shadow-2xl aspect-video bg-zinc-900 flex items-center justify-center">
                    {/* Using a placeholder SVG-like UI for now */}
                    <div className="w-full h-full p-8 flex flex-col gap-4">
                      <div className="h-8 w-1/3 bg-white/10 rounded-md" />
                      <div className="flex-1 grid grid-cols-2 gap-4">
                        <div className="bg-white/5 rounded-xl border border-white/10" />
                        <div className="bg-white/5 rounded-xl border border-white/10" />
                      </div>
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
