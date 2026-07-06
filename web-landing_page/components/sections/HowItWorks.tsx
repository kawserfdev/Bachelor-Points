"use client";

import { motion } from "framer-motion";

const steps = [
  {
    number: "01",
    title: "Create Group",
    description: "মেস ম্যানেজার হিসেবে একটি গ্রুপ ক্রিয়েট করুন এবং মেম্বারদের ইনভাইট লিংক পাঠিয়ে দিন।",
  },
  {
    number: "02",
    title: "Add Members",
    description: "মেম্বাররা ইনভাইট লিংকে ক্লিক করে আপনার গ্রুপে জয়েন করবে। আপনি তাদের পারমিশন সেট করতে পারবেন।",
  },
  {
    number: "03",
    title: "Start Tracking",
    description: "প্রতিদিনের মিল এবং বাজার খরচ এন্ট্রি করা শুরু করুন। অ্যাপ অটোমেটিক সব হিসাব আপডেট রাখবে।",
  },
  {
    number: "04",
    title: "Review & Settle",
    description: "মাসের শেষে মিল রেট এবং সবার ব্যালেন্স দেখে পেমেন্ট সেটেল করুন। কোনো কনফিউশন ছাড়াই!",
  },
];

export function HowItWorks() {
  return (
    <section id="how-it-works" className="py-24 bg-zinc-50 dark:bg-zinc-950/50">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div className="text-center mb-16">
          <motion.h2
            initial={{ opacity: 0, y: 20 }}
            whileInView={{ opacity: 1, y: 0 }}
            viewport={{ once: true }}
            className="text-3xl md:text-5xl font-bold mb-4"
          >
            কিভাবে কাজ করে?
          </motion.h2>
          <p className="text-muted-foreground text-lg max-w-2xl mx-auto">
            মাত্র ৪টি সহজ ধাপে আপনার মেস লাইফকে ডিজিটাল করে ফেলুন।
          </p>
        </div>

        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-12">
          {steps.map((step, index) => (
            <motion.div
              key={index}
              initial={{ opacity: 0, y: 20 }}
              whileInView={{ opacity: 1, y: 0 }}
              viewport={{ once: true }}
              transition={{ delay: index * 0.1 }}
              className="relative"
            >
              <div className="text-6xl font-black text-primary/10 absolute -top-10 -left-4">
                {step.number}
              </div>
              <div className="relative z-10">
                <h3 className="text-xl font-bold mb-4">{step.title}</h3>
                <p className="text-muted-foreground leading-relaxed">
                  {step.description}
                </p>
              </div>
              {index < steps.length - 1 && (
                <div className="hidden lg:block absolute top-6 -right-6 w-12 border-t-2 border-dashed border-border/50" />
              )}
            </motion.div>
          ))}
        </div>
      </div>
    </section>
  );
}
