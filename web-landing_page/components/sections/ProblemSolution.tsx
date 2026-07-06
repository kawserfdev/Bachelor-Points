"use client";

import { motion } from "framer-motion";
import { XCircle, CheckCircle2 } from "lucide-react";

const problems = [
  "খাতা-কলমে হিসাবের ঝামেলা",
  "মিল রেট বের করতে ঘণ্টার পর ঘণ্টা ক্যালকুলেশন",
  "মেস মেম্বারদের মধ্যে হিসাব নিয়ে ভুল বোঝাবুঝি",
  "টাকা পয়সার কোনো রিয়েল-টাইম আপডেট না থাকা",
];

const solutions = [
  "পুরো ডিজিটাল মেস ম্যানেজমেন্ট সিস্টেম",
  "অটোমেটিক মিল রেট এবং ব্যালেন্স ক্যালকুলেশন",
  "স্বচ্ছ হিসাব, তাই সবার মধ্যে বিশ্বাস থাকবে",
  "যেকোনো সময় যেকোনো ডিভাইস থেকে আপডেট দেখুন",
];

export function ProblemSolution() {
  return (
    <section className="py-24 bg-white dark:bg-black overflow-hidden">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div className="grid grid-cols-1 lg:grid-cols-2 gap-16 items-center">
          {/* Problem Side */}
          <motion.div
            initial={{ opacity: 0, x: -50 }}
            whileInView={{ opacity: 1, x: 0 }}
            viewport={{ once: true }}
            className="space-y-8"
          >
            <div>
              <h2 className="text-3xl font-bold mb-4 flex items-center gap-3">
                <span className="text-red-500">The Problem</span>
              </h2>
              <p className="text-muted-foreground text-lg">
                আপনি কি এখনও সেই মান্ধাতা আমলের খাতা-কলম ব্যবহার করে মেসের হিসাব রাখছেন?
              </p>
            </div>
            <ul className="space-y-4">
              {problems.map((p, i) => (
                <li key={i} className="flex items-start gap-3 p-4 rounded-2xl bg-red-500/5 border border-red-500/10">
                  <XCircle className="w-6 h-6 text-red-500 shrink-0 mt-0.5" />
                  <span className="text-foreground/80">{p}</span>
                </li>
              ))}
            </ul>
          </motion.div>

          {/* Solution Side */}
          <motion.div
            initial={{ opacity: 0, x: 50 }}
            whileInView={{ opacity: 1, x: 0 }}
            viewport={{ once: true }}
            className="space-y-8"
          >
            <div>
              <h2 className="text-3xl font-bold mb-4 flex items-center gap-3">
                <span className="text-emerald-500">The Solution</span>
              </h2>
              <p className="text-muted-foreground text-lg">
                Mess Manager-এর মাধ্যমে আপনার মেস লাইফকে করুন আরও স্মার্ট এবং ঝামেলামুক্ত।
              </p>
            </div>
            <ul className="space-y-4">
              {solutions.map((s, i) => (
                <li key={i} className="flex items-start gap-3 p-4 rounded-2xl bg-emerald-500/5 border border-emerald-500/10">
                  <CheckCircle2 className="w-6 h-6 text-emerald-500 shrink-0 mt-0.5" />
                  <span className="text-foreground/80">{s}</span>
                </li>
              ))}
            </ul>
          </motion.div>
        </div>
      </div>
    </section>
  );
}
