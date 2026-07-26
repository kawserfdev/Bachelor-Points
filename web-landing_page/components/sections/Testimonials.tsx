"use client";

import { motion } from "framer-motion";
import { Star, Quote } from "lucide-react";

const testimonials = [
  {
    name: "Tanvir Ahmed",
    role: "University Student, Dhaka",
    text: "We used to argue every month about who ate what. BachelorPoints made everything automatic — the meal rate, the balance, all of it. Our mess life is actually peaceful now.",
    rating: 5,
    avatar: "TA",
    color: "bg-primary/10 text-primary",
  },
  {
    name: "Sajid Hasan",
    role: "Job Holder, Shared Flat",
    text: "As a mess manager, calculating the meal rate at month end was my biggest headache. Now the app does it in one click. This is a genuine lifesaver for anyone managing a mess.",
    rating: 5,
    avatar: "SH",
    color: "bg-emerald-500/10 text-emerald-600 dark:text-emerald-400",
  },
  {
    name: "Rifat Jahan",
    role: "Hostel Resident, Chittagong",
    text: "The to-post feature is brilliant. We had two empty seats and filled them within a day through the app. The UI is clean, fast, and actually enjoyable to use.",
    rating: 5,
    avatar: "RJ",
    color: "bg-accent/10 text-accent",
  },
];

export function Testimonials() {
  return (
    <section id="testimonials" className="py-20 lg:py-28 relative">
      <div className="max-w-6xl mx-auto px-5 sm:px-8">
        {/* Section header - left aligned */}
        <div className="max-w-2xl mb-14">
          <motion.span
            initial={{ opacity: 0, y: 10 }}
            whileInView={{ opacity: 1, y: 0 }}
            viewport={{ once: true }}
            className="text-[11px] font-bold uppercase tracking-widest text-primary"
          >
            Testimonials
          </motion.span>
          <motion.h2
            initial={{ opacity: 0, y: 15 }}
            whileInView={{ opacity: 1, y: 0 }}
            viewport={{ once: true }}
            transition={{ delay: 0.05 }}
            className="text-3xl sm:text-4xl font-extrabold tracking-[-0.02em] mt-4 mb-3 leading-[1.1]"
          >
            Trusted by thousands
            <br />
            of mess members.
          </motion.h2>
          <motion.p
            initial={{ opacity: 0, y: 15 }}
            whileInView={{ opacity: 1, y: 0 }}
            viewport={{ once: true }}
            transition={{ delay: 0.1 }}
            className="text-muted-foreground text-[15px] leading-relaxed"
          >
            Real feedback from students, job holders, and hostel residents across
            Bangladesh.
          </motion.p>
        </div>

        {/* Testimonial cards */}
        <div className="grid sm:grid-cols-2 lg:grid-cols-3 gap-5">
          {testimonials.map((t, index) => (
            <motion.div
              key={index}
              initial={{ opacity: 0, y: 20 }}
              whileInView={{ opacity: 1, y: 0 }}
              viewport={{ once: true }}
              transition={{ duration: 0.4, delay: index * 0.08 }}
              className="p-6 rounded-xl border border-border/40 bg-card flex flex-col justify-between"
            >
              <div>
                {/* Quote icon */}
                <Quote className="w-5 h-5 text-primary/20 mb-3" />

                {/* Rating */}
                <div className="flex items-center gap-0.5 mb-4">
                  {[...Array(t.rating)].map((_, i) => (
                    <Star
                      key={i}
                      className="w-3.5 h-3.5 fill-primary text-primary"
                    />
                  ))}
                </div>

                <p className="text-[13px] sm:text-sm leading-relaxed text-foreground/80 font-medium mb-6">
                  &ldquo;{t.text}&rdquo;
                </p>
              </div>

              {/* Author */}
              <div className="flex items-center gap-3 pt-4 border-t border-border/30">
                <div
                  className={`w-9 h-9 rounded-full ${t.color} flex items-center justify-center font-bold text-[11px]`}
                >
                  {t.avatar}
                </div>
                <div>
                  <p className="text-[13px] font-bold text-foreground">
                    {t.name}
                  </p>
                  <p className="text-[11px] text-muted-foreground font-medium">
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
