"use client";

import { motion } from "framer-motion";

const steps = [
  {
    number: "01",
    title: "Create your mess group",
    description:
      "Sign up, create a group, and invite members using a unique 6-digit code.",
  },
  {
    number: "02",
    title: "Members join instantly",
    description:
      "Members enter the invite code to join. You set roles and permissions.",
  },
  {
    number: "03",
    title: "Track meals & expenses daily",
    description:
      "Log meals, add bazar expenses, and let the app handle the math automatically.",
  },
  {
    number: "04",
    title: "Review & settle at month end",
    description:
      "See who owes, who paid, and download a PDF report. Zero confusion.",
  },
];

export function HowItWorks() {
  return (
    <section id="how-it-works" className="py-20 lg:py-28 relative">
      <div className="max-w-6xl mx-auto px-5 sm:px-8">
        {/* Section header */}
        <div className="max-w-2xl mb-14">
          <motion.span
            initial={{ opacity: 0, y: 10 }}
            whileInView={{ opacity: 1, y: 0 }}
            viewport={{ once: true }}
            className="text-[11px] font-bold uppercase tracking-widest text-primary"
          >
            How It Works
          </motion.span>
          <motion.h2
            initial={{ opacity: 0, y: 15 }}
            whileInView={{ opacity: 1, y: 0 }}
            viewport={{ once: true }}
            transition={{ delay: 0.05 }}
            className="text-3xl sm:text-4xl font-extrabold tracking-[-0.02em] mt-4 mb-3 leading-[1.1]"
          >
            Four steps to a
            <br />
            peaceful mess life.
          </motion.h2>
          <motion.p
            initial={{ opacity: 0, y: 15 }}
            whileInView={{ opacity: 1, y: 0 }}
            viewport={{ once: true }}
            transition={{ delay: 0.1 }}
            className="text-muted-foreground text-[15px] leading-relaxed"
          >
            Getting started takes less than 2 minutes. No setup fees, no
            complicated onboarding.
          </motion.p>
        </div>

        {/* Timeline */}
        <div className="relative">
          {/* Vertical line */}
          <div className="absolute left-[19px] sm:left-[23px] top-0 bottom-0 w-px bg-border/50" />

          <div className="space-y-1">
            {steps.map((step, index) => (
              <motion.div
                key={index}
                initial={{ opacity: 0, y: 15 }}
                whileInView={{ opacity: 1, y: 0 }}
                viewport={{ once: true }}
                transition={{ duration: 0.4, delay: index * 0.08 }}
                className="relative flex gap-5 sm:gap-6"
              >
                {/* Step number circle */}
                <div className="relative z-10 shrink-0">
                  <div className="w-10 h-10 sm:w-12 sm:h-12 rounded-full bg-card border-2 border-primary/20 flex items-center justify-center shadow-sm">
                    <span className="text-[11px] sm:text-xs font-extrabold text-primary">
                      {step.number}
                    </span>
                  </div>
                </div>

                {/* Step content */}
                <div className="pt-1.5 sm:pt-2.5 pb-8">
                  <h3 className="text-[15px] sm:text-base font-bold text-foreground mb-1.5">
                    {step.title}
                  </h3>
                  <p className="text-muted-foreground text-[13px] sm:text-sm leading-relaxed max-w-md">
                    {step.description}
                  </p>
                </div>
              </motion.div>
            ))}
          </div>
        </div>
      </div>
    </section>
  );
}
