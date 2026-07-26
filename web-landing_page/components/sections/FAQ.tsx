"use client";

import {
  Accordion,
  AccordionContent,
  AccordionItem,
  AccordionTrigger,
} from "@/components/ui/accordion";
import { motion } from "framer-motion";

const faqs = [
  {
    question: "Is BachelorPoints free?",
    answer:
      "Yes. All core features — meal tracking, expense management, automatic calculations, and reports — are completely free. We may introduce premium features in the future, but the essentials will always be free.",
  },
  {
    question: "How do I get started?",
    answer:
      "Sign up with your email or Google account. Create a mess group, share the invite code with your members, and start tracking meals and expenses. The whole process takes less than 2 minutes.",
  },
  {
    question: "Can I use it for my hostel or shared flat?",
    answer:
      "Absolutely. BachelorPoints works for any shared living arrangement — bachelor messes, hostels, shared apartments, or flat-shares. Any setup where people split meal and living costs.",
  },
  {
    question: "Is my data secure?",
    answer:
      "Your data is stored in a secure cloud database and is never shared with third parties. Only your mess group members and managers can see your information. We take data privacy seriously.",
  },
  {
    question: "Does it work offline?",
    answer:
      "Currently, an internet connection is required for real-time sync. However, we're actively working on offline meal entry support so you can log data without connectivity and sync when you're back online.",
  },
];

export function FAQ() {
  return (
    <section id="faq" className="py-20 lg:py-28 relative">
      <div className="max-w-3xl mx-auto px-5 sm:px-8">
        {/* Section header - centered for this narrow section */}
        <div className="text-center mb-12">
          <motion.span
            initial={{ opacity: 0, y: 10 }}
            whileInView={{ opacity: 1, y: 0 }}
            viewport={{ once: true }}
            className="text-[11px] font-bold uppercase tracking-widest text-primary"
          >
            FAQ
          </motion.span>
          <motion.h2
            initial={{ opacity: 0, y: 15 }}
            whileInView={{ opacity: 1, y: 0 }}
            viewport={{ once: true }}
            transition={{ delay: 0.05 }}
            className="text-3xl sm:text-4xl font-extrabold tracking-[-0.02em] mt-4 mb-3 leading-[1.1]"
          >
            Common questions.
          </motion.h2>
          <motion.p
            initial={{ opacity: 0, y: 15 }}
            whileInView={{ opacity: 1, y: 0 }}
            viewport={{ once: true }}
            transition={{ delay: 0.1 }}
            className="text-muted-foreground text-[15px] leading-relaxed"
          >
            Quick answers to what people usually ask.
          </motion.p>
        </div>

        <motion.div
          initial={{ opacity: 0, y: 15 }}
          whileInView={{ opacity: 1, y: 0 }}
          viewport={{ once: true }}
          transition={{ duration: 0.4 }}
        >
          <Accordion type="single" collapsible className="space-y-3">
            {faqs.map((faq, index) => (
              <AccordionItem
                key={index}
                value={`item-${index}`}
                className="border border-border/40 bg-card rounded-xl px-5"
              >
                <AccordionTrigger className="text-left text-[14px] font-semibold py-4 hover:no-underline hover:text-primary transition-colors">
                  {faq.question}
                </AccordionTrigger>
                <AccordionContent className="text-muted-foreground text-[13px] leading-relaxed pb-4 font-medium">
                  {faq.answer}
                </AccordionContent>
              </AccordionItem>
            ))}
          </Accordion>
        </motion.div>
      </div>
    </section>
  );
}
