"use client";

import {
  Accordion,
  AccordionContent,
  AccordionItem,
  AccordionTrigger,
} from "@/components/ui/accordion";
import { motion } from "framer-motion";

export function FAQ() {
  const faqs = [
    {
      question: "Is BachelorPoints free to use?",
      answer:
        "Yes! All essential features — daily meal tracking, bazar & expense logging, automated calculations, member ledgers, and monthly PDF reports — are completely free for all messes.",
    },
    {
      question: "Can I use BachelorPoints without internet (Offline mode)?",
      answer:
        "Yes. BachelorPoints is designed with offline-ready meal logging. You can mark your daily meals even with low or zero internet connectivity. Once your phone reconnects, changes sync automatically to the cloud.",
    },
    {
      question: "Can multiple members join and manage the same mess?",
      answer:
        "Absolutely. As a manager, you get a unique 6-digit mess invite code (e.g. #DHAN-742). All members join with this code and can view meals, balances, and bazar schedules on their own devices.",
    },
    {
      question: "How is the meal rate calculated?",
      answer:
        "BachelorPoints uses the standard Bangladeshi mess calculation formula: Total Shared Bazar Expenses ÷ Total Consumed Meals = Meal Rate. Individual costs are then: (Member's Meals × Meal Rate) + Fixed Individual Costs. Your Balance = Deposit − Total Cost.",
    },
    {
      question: "Can I edit my meal count after logging?",
      answer:
        "Yes, members can adjust meal portions (0.5, 1.0, 1.5, 2.0) up until the mess cut-off time (e.g., 10:00 PM) configured by the manager. After the cut-off, meals auto-lock to prevent disputes.",
    },
    {
      question: "Can I add guest meals for visitors and friends?",
      answer:
        "Yes. You can add extra guest meals directly under your profile. The meal rate and expense math will automatically bill the guest meal to your individual balance.",
    },
    {
      question: "Can I download and share monthly PDF reports?",
      answer:
        "Yes! At the end of every month, you can export a comprehensive PDF report showing total meals, bazar breakdown, individual deposits, costs, and final credit/due balances ready to share on WhatsApp.",
    },
    {
      question: "Can we change or rotate the mess manager?",
      answer:
        "Yes. The current manager can transfer or delegate the manager role to another member at any time without losing any historical data or member balance sheets.",
    },
    {
      question: "Is our mess financial data secure and private?",
      answer:
        "Yes. Your data is stored securely in encrypted cloud databases. Only verified members in your specific mess group can view your records, and your data is never sold to third parties.",
    },
    {
      question: "Can I access BachelorPoints from another phone or computer?",
      answer:
        "Yes. Your account is tied to your phone/email. You can log in from any Android, iPhone, tablet, or modern laptop browser and access the exact same live mess dashboard.",
    },
  ];

  return (
    <section id="faq" className="py-20 lg:py-28 relative">
      <div className="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8">
        {/* Header */}
        <div className="text-center max-w-2xl mx-auto mb-14">
          <motion.span
            initial={{ opacity: 0, y: 10 }}
            whileInView={{ opacity: 1, y: 0 }}
            viewport={{ once: true }}
            className="text-xs font-bold uppercase tracking-widest text-[#8B3DFF] bg-[#8B3DFF]/10 px-3.5 py-1.5 rounded-full border border-[#8B3DFF]/20"
          >
            Got Questions?
          </motion.span>
          <motion.h2
            initial={{ opacity: 0, y: 15 }}
            whileInView={{ opacity: 1, y: 0 }}
            viewport={{ once: true }}
            transition={{ delay: 0.05 }}
            className="text-3xl sm:text-4xl lg:text-5xl font-extrabold tracking-tight mt-4 mb-4 text-balance"
          >
            Frequently Asked Questions.
          </motion.h2>
          <motion.p
            initial={{ opacity: 0, y: 15 }}
            whileInView={{ opacity: 1, y: 0 }}
            viewport={{ once: true }}
            transition={{ delay: 0.1 }}
            className="text-muted-foreground text-base sm:text-lg leading-relaxed font-normal"
          >
            Everything you need to know about setting up and running your mess.
          </motion.p>
        </div>

        {/* Accordion List */}
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          whileInView={{ opacity: 1, y: 0 }}
          viewport={{ once: true }}
          transition={{ duration: 0.4 }}
        >
          <Accordion type="single" collapsible className="space-y-3">
            {faqs.map((faq, index) => (
              <AccordionItem
                key={index}
                value={`faq-${index}`}
                className="border border-border/70 bg-card rounded-2xl px-5 sm:px-6 shadow-sm overflow-hidden"
              >
                <AccordionTrigger className="text-left text-sm sm:text-base font-bold py-4 sm:py-5 hover:no-underline hover:text-[#8B3DFF] transition-colors cursor-pointer">
                  {faq.question}
                </AccordionTrigger>
                <AccordionContent className="text-muted-foreground text-xs sm:text-sm leading-relaxed pb-5 font-normal">
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
