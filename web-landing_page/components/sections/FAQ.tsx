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
    question: "BachelorPoints কি ফ্রি?",
    answer: "হ্যাঁ! বেসিক ফিচারের জন্য BachelorPoints একদম ফ্রি। তবে আমরা ভবিষ্যতে কিছু প্রিমিয়াম ফিচার নিয়ে আসবো যা আপনার মেস লাইফকে আরও সহজ করবে।",
  },
  {
    question: "কিভাবে শুরু করবো?",
    answer: "প্রথমে সাইন আপ করুন, একটি গ্রুপ ক্রিয়েট করুন এবং মেম্বারদের ইনভাইট দিন। ব্যাস! এরপর থেকেই আপনারা মিল এবং খরচের হিসাব রাখা শুরু করতে পারবেন।",
  },
  {
    question: "আমরা কি আমাদের হোস্টেলে এটি ব্যবহার করতে পারবো?",
    answer: "অবশ্যই! এটি যেকোনো শেয়ার্ড অ্যাপার্টমেন্ট, হোস্টেল বা ব্যাসেলর মেসের জন্য আদর্শ।",
  },
  {
    question: "আমার ডাটা কি সিকিউর?",
    answer: "আপনার ডাটা এনক্রিপ্টেড থাকে এবং আমরা কখনো আপনার ব্যক্তিগত তথ্য থার্ড পার্টির সাথে শেয়ার করি না।",
  },
  {
    question: "অফলাইনে কি এটি ব্যবহার করা যাবে?",
    answer: "আপাতত ডাটা সিঙ্ক করার জন্য ইন্টারনেট কানেকশন প্রয়োজন। তবে আমরা ভবিষ্যতে অফলাইন সাপোর্ট নিয়ে কাজ করার পরিকল্পনা করছি।",
  },
];

export function FAQ() {
  return (
    <section id="faq" className="py-24 bg-zinc-50/50 dark:bg-zinc-950/50">
      <div className="max-w-3xl mx-auto px-4 sm:px-6 lg:px-8">
        <div className="text-center mb-16">
          <motion.h2
            initial={{ opacity: 0, y: 20 }}
            whileInView={{ opacity: 1, y: 0 }}
            viewport={{ once: true }}
            className="text-3xl md:text-5xl font-bold mb-4"
          >
            সাধারণ কিছু জিজ্ঞাসা
          </motion.h2>
          <p className="text-muted-foreground text-lg">
            আপনার মনে থাকা কমন প্রশ্নগুলোর উত্তর এখানে পাবেন।
          </p>
        </div>

        <motion.div
          initial={{ opacity: 0, y: 20 }}
          whileInView={{ opacity: 1, y: 0 }}
          viewport={{ once: true }}
        >
          <Accordion type="single" collapsible className="w-full">
            {faqs.map((faq, index) => (
              <AccordionItem key={index} value={`item-${index}`} className="border-border/50">
                <AccordionTrigger className="text-left text-lg font-medium hover:no-underline hover:text-primary">
                  {faq.question}
                </AccordionTrigger>
                <AccordionContent className="text-muted-foreground text-base leading-relaxed">
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