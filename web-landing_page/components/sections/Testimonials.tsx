"use client";

import { motion } from "framer-motion";
import { Star, Quote } from "lucide-react";

export function Testimonials() {
  const testimonials = [
    {
      name: "Tanvir Ahmed",
      role: "University Student • Dhanmondi, Dhaka",
      text: "We used to argue every month about who ate what and who owes how much. BachelorPoints made everything automated — the meal rate, deposits, and individual balances. Our mess life is completely peaceful now.",
      rating: 5,
      avatar: "TA",
      color: "bg-[#8B3DFF]/15 text-[#8B3DFF]",
    },
    {
      name: "Sajid Hasan",
      role: "Software Engineer • Shared Flat, Mirpur",
      text: "As the mess manager for 8 flatmates, calculating the meal rate at month-end was my biggest headache. Now BachelorPoints auto-calculates everything in one click and exports a clean PDF report.",
      rating: 5,
      avatar: "SH",
      color: "bg-emerald-500/15 text-emerald-600 dark:text-emerald-400",
    },
    {
      name: "Rifat Hossain",
      role: "Hostel Resident • Nasirabad, Chittagong",
      text: "The bazar duty reminder and live shopping checklist are pure genius. No more confused morning phone calls about what vegetables or oil to buy. The app is fast, clean, and zero-hassle.",
      rating: 5,
      avatar: "RH",
      color: "bg-[#A855F7]/15 text-[#A855F7]",
    },
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
            className="text-xs font-bold uppercase tracking-widest text-[#8B3DFF] bg-[#8B3DFF]/10 px-3.5 py-1.5 rounded-full border border-[#8B3DFF]/20"
          >
            Community Voices
          </motion.span>
          <motion.h2
            initial={{ opacity: 0, y: 15 }}
            whileInView={{ opacity: 1, y: 0 }}
            viewport={{ once: true }}
            transition={{ delay: 0.05 }}
            className="text-3xl sm:text-4xl lg:text-5xl font-extrabold tracking-tight mt-4 mb-4 text-balance"
          >
            Loved by Bachelors Across Bangladesh.
          </motion.h2>
          <motion.p
            initial={{ opacity: 0, y: 15 }}
            whileInView={{ opacity: 1, y: 0 }}
            viewport={{ once: true }}
            transition={{ delay: 0.1 }}
            className="text-muted-foreground text-base sm:text-lg leading-relaxed font-normal"
          >
            Real experiences from students, job holders, and hostel communities.
          </motion.p>
        </div>

        {/* 3 Testimonials */}
        <div className="grid sm:grid-cols-2 lg:grid-cols-3 gap-6">
          {testimonials.map((t, index) => (
            <motion.div
              key={index}
              initial={{ opacity: 0, y: 20 }}
              whileInView={{ opacity: 1, y: 0 }}
              viewport={{ once: true }}
              transition={{ duration: 0.4, delay: index * 0.08 }}
              className="p-6 sm:p-7 rounded-2xl bg-card border border-border/70 flex flex-col justify-between hover:border-[#8B3DFF]/30 transition-all shadow-sm"
            >
              <div>
                <Quote className="w-6 h-6 text-[#8B3DFF]/30 mb-4" />
                <div className="flex items-center gap-1 mb-4">
                  {[...Array(t.rating)].map((_, i) => (
                    <Star
                      key={i}
                      className="w-4 h-4 fill-amber-400 text-amber-400"
                    />
                  ))}
                </div>
                <p className="text-xs sm:text-sm text-foreground/90 leading-relaxed font-medium mb-6">
                  &ldquo;{t.text}&rdquo;
                </p>
              </div>

              <div className="flex items-center gap-3 pt-4 border-t border-border/40">
                <div
                  className={`w-10 h-10 rounded-xl ${t.color} flex items-center justify-center font-bold text-xs`}
                >
                  {t.avatar}
                </div>
                <div>
                  <h4 className="text-xs sm:text-sm font-bold text-foreground">
                    {t.name}
                  </h4>
                  <p className="text-[11px] text-muted-foreground">
                    {t.role}
                  </p>
                </div>
              </div>
            </motion.div>
          ))}
        </div>
      </div>
    </section>
  );
}
