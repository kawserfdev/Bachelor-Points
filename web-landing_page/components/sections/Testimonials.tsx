"use client";

import { motion } from "framer-motion";
import { Quote } from "lucide-react";

const testimonials = [
  {
    name: "Tanvir Ahmed",
    role: "University Student",
    text: "আগে মেসের হিসাব নিয়ে প্রতিদিন ঝগড়া হতো। BachelorPoints আসার পর থেকে আমাদের মেসের পরিবেশ এখন অনেক শান্ত। অটোমেটিক ক্যালকুলেশন জাস্ট অসাম!",
  },
  {
    name: "Sajid Hasan",
    role: "Job Holder, Shared Flat",
    text: "মাসের শেষে মিল রেট বের করা ছিল সবচেয়ে বড় প্যারা। এখন অ্যাপেই সব রেডি থাকে। মেসের ম্যানেজারের জন্য এটি একটি লাইফ সেভার অ্যাপ!",
  },
  {
    name: "Rifat Jahan",
    role: "Hostel Resident",
    text: "টু-লেট পোস্ট করার ফিচারটা দারুণ। আমাদের মেসের খালি সিটগুলো এখন খুব সহজেই পূরণ হয়ে যায়। UI খুবই ক্লিন এবং ইউজার ফ্রেন্ডলি।",
  },
];

export function Testimonials() {
  return (
    <section className="py-24 relative overflow-hidden">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div className="text-center mb-16">
          <motion.h2
            initial={{ opacity: 0, y: 20 }}
            whileInView={{ opacity: 1, y: 0 }}
            viewport={{ once: true }}
            className="text-3xl md:text-5xl font-bold mb-4"
          >
            মেস মেম্বাররা যা বলছে
          </motion.h2>
        </div>

        <div className="grid grid-cols-1 md:grid-cols-3 gap-8">
          {testimonials.map((t, index) => (
            <motion.div
              key={index}
              initial={{ opacity: 0, scale: 0.95 }}
              whileInView={{ opacity: 1, scale: 1 }}
              viewport={{ once: true }}
              transition={{ delay: index * 0.1 }}
              className="p-8 rounded-3xl border border-border/50 bg-card/50 backdrop-blur-sm relative"
            >
              <Quote className="absolute top-6 right-8 w-10 h-10 text-primary/10" />
              <p className="text-lg italic mb-6 leading-relaxed">"{t.text}"</p>
              <div className="flex items-center gap-4">
                <div className="w-12 h-12 rounded-full bg-primary/20 flex items-center justify-center font-bold text-primary">
                  {t.name[0]}
                </div>
                <div>
                  <p className="font-bold">{t.name}</p>
                  <p className="text-sm text-muted-foreground">{t.role}</p>
                </div>
              </div>
            </motion.div>
          ))}
        </div>
      </div>
    </section>
  );
}
