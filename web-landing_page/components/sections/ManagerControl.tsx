"use client";

import { motion } from "framer-motion";
import {
  Users,
  CheckCheck,
  Clock,
  UserCheck,
  FileSpreadsheet,
  Settings2,
} from "lucide-react";

export function ManagerControl() {
  const managerPowers = [
    {
      icon: Users,
      title: "Member & Invite Management",
      desc: "Generate custom 6-digit invite codes, review join requests, and manage flat members effortlessly.",
      badge: "Members",
    },
    {
      icon: CheckCheck,
      title: "Expense & Deposit Approvals",
      desc: "Review bazar receipts and member deposit transactions before they affect the active mess balance sheet.",
      badge: "Approvals",
    },
    {
      icon: Clock,
      title: "Custom Cut-off Times",
      desc: "Lock meal entries automatically every evening (e.g. 10:00 PM) to prevent last-minute surprise changes.",
      badge: "Automation",
    },
    {
      icon: UserCheck,
      title: "Seamless Manager Handover",
      desc: "Rotate the mess manager role smoothly at month-end without losing any historical financial records.",
      badge: "Delegation",
    },
    {
      icon: FileSpreadsheet,
      title: "One-Click Month End Audits",
      desc: "Generate complete balance summaries, calculate final meal rates, and share official PDF reports.",
      badge: "Reports",
    },
    {
      icon: Settings2,
      title: "Role Hierarchy & Permissions",
      desc: "Assign granular Admin, Manager, and Member permissions to maintain full operational accountability.",
      badge: "Security",
    },
  ];

  return (
    <section id="manager-control" className="py-20 lg:py-28 relative bg-secondary/20 border-y border-border/40">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        {/* Header */}
        <div className="text-center max-w-3xl mx-auto mb-16">
          <motion.span
            initial={{ opacity: 0, y: 10 }}
            whileInView={{ opacity: 1, y: 0 }}
            viewport={{ once: true }}
            className="text-xs font-bold uppercase tracking-widest text-[#8B3DFF] bg-[#8B3DFF]/10 px-3.5 py-1.5 rounded-full border border-[#8B3DFF]/20"
          >
            Manager Authority
          </motion.span>
          <motion.h2
            initial={{ opacity: 0, y: 15 }}
            whileInView={{ opacity: 1, y: 0 }}
            viewport={{ once: true }}
            transition={{ delay: 0.05 }}
            className="text-3xl sm:text-4xl lg:text-5xl font-extrabold tracking-tight mt-4 mb-4 text-balance"
          >
            Mess Management Without the Chaos.
          </motion.h2>
          <motion.p
            initial={{ opacity: 0, y: 15 }}
            whileInView={{ opacity: 1, y: 0 }}
            viewport={{ once: true }}
            transition={{ delay: 0.1 }}
            className="text-muted-foreground text-base sm:text-lg leading-relaxed font-normal"
          >
            Whether you&apos;re managing a 4-person flat or a 30-resident student hostel,
            BachelorPoints gives you full administrative control with zero stress.
          </motion.p>

          {/* Role Badges */}
          <div className="flex items-center justify-center gap-2.5 mt-6">
            <span className="text-xs font-bold px-3 py-1 rounded-full bg-[#8B3DFF]/15 text-[#8B3DFF] border border-[#8B3DFF]/25">
              👑 Admin
            </span>
            <span className="text-xs font-bold px-3 py-1 rounded-full bg-[#A855F7]/15 text-[#A855F7] border border-[#A855F7]/25">
              🛡️ Manager
            </span>
            <span className="text-xs font-bold px-3 py-1 rounded-full bg-secondary text-muted-foreground border border-border/50">
              👤 Member
            </span>
          </div>
        </div>

        {/* 6 Manager Feature Cards */}
        <div className="grid sm:grid-cols-2 lg:grid-cols-3 gap-6">
          {managerPowers.map((power, index) => {
            const Icon = power.icon;
            return (
              <motion.div
                key={index}
                initial={{ opacity: 0, y: 20 }}
                whileInView={{ opacity: 1, y: 0 }}
                viewport={{ once: true }}
                transition={{ duration: 0.4, delay: index * 0.07 }}
                className="p-6 rounded-2xl bg-card border border-border/70 hover:border-[#8B3DFF]/40 transition-all flex flex-col justify-between"
              >
                <div>
                  <div className="flex items-center justify-between mb-4">
                    <div className="w-10 h-10 rounded-xl bg-[#8B3DFF]/15 text-[#8B3DFF] flex items-center justify-center">
                      <Icon className="w-5 h-5" />
                    </div>
                    <span className="text-[10px] font-bold uppercase tracking-wider text-muted-foreground bg-secondary px-2 py-0.5 rounded">
                      {power.badge}
                    </span>
                  </div>

                  <h3 className="text-base font-bold text-foreground mb-2">
                    {power.title}
                  </h3>
                  <p className="text-xs sm:text-sm text-muted-foreground leading-relaxed">
                    {power.desc}
                  </p>
                </div>
              </motion.div>
            );
          })}
        </div>
      </div>
    </section>
  );
}
