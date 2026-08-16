"use client";

import { motion } from "framer-motion";
import { ShoppingBag, Bell, UserCheck } from "lucide-react";
import { useState } from "react";

export function SmartBazar() {
  const [items, setItems] = useState([
    { name: "Miniket Rice (চাল - ২৫ কেজি)", checked: true },
    { name: "Masoor Dal (মসুর ডাল - ২ কেজি)", checked: true },
    { name: "Potatoes & Onions (আলু ও পেঁয়াজ)", checked: true },
    { name: "Soybean Oil (তীর সয়াবিন তেল - ৫ লিটার)", checked: true },
    { name: "Farm Eggs (ফার্মের লাল ডিম - ২ ডজন)", checked: false },
    { name: "Fresh Green Vegetables (শাক-সবজি)", checked: false },
  ]);

  const toggleItem = (index: number) => {
    setItems((prev) =>
      prev.map((item, i) =>
        i === index ? { ...item, checked: !item.checked } : item
      )
    );
  };

  return (
    <section id="smart-bazar" className="py-20 lg:py-28 relative">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div className="grid lg:grid-cols-12 gap-10 lg:gap-14 items-center">
          {/* Left Description */}
          <motion.div
            initial={{ opacity: 0, x: -20 }}
            whileInView={{ opacity: 1, x: 0 }}
            viewport={{ once: true }}
            transition={{ duration: 0.5 }}
            className="lg:col-span-6 space-y-6"
          >
            <span className="text-xs font-bold uppercase tracking-widest text-[#A855F7] bg-[#A855F7]/10 px-3.5 py-1.5 rounded-full border border-[#A855F7]/20">
              Smart Bazar Management
            </span>

            <h2 className="text-3xl sm:text-4xl lg:text-5xl font-extrabold tracking-tight text-foreground leading-[1.15]">
              From &ldquo;কি বাজার করবো?&rdquo;
              <br />
              <span className="bg-gradient-to-r from-[#8B3DFF] to-[#A855F7] bg-clip-text text-transparent">
                to &ldquo;সব Ready.&rdquo;
              </span>
            </h2>

            <p className="text-muted-foreground text-base sm:text-lg leading-relaxed font-normal">
              No more chaotic morning phone calls or forgotten grocery items.
              BachelorPoints organizes the entire mess shopping cycle with automated duty rotation,
              live checklists, and 8:00 AM push reminders.
            </p>

            <div className="space-y-3 pt-2">
              <div className="flex items-start gap-3">
                <div className="w-6 h-6 rounded-lg bg-emerald-500/15 text-emerald-500 flex items-center justify-center shrink-0 mt-0.5 font-bold">
                  ✓
                </div>
                <div>
                  <h4 className="text-sm font-bold text-foreground">
                    Know what to buy
                  </h4>
                  <p className="text-xs text-muted-foreground">
                    Collaborative shopping list created and updated directly by mess members.
                  </p>
                </div>
              </div>

              <div className="flex items-start gap-3">
                <div className="w-6 h-6 rounded-lg bg-[#8B3DFF]/15 text-[#8B3DFF] flex items-center justify-center shrink-0 mt-0.5 font-bold">
                  ✓
                </div>
                <div>
                  <h4 className="text-sm font-bold text-foreground">
                    Know who&apos;s going
                  </h4>
                  <p className="text-xs text-muted-foreground">
                    Automated duty assignment calendar so everyone takes equal turns without disputes.
                  </p>
                </div>
              </div>

              <div className="flex items-start gap-3">
                <div className="w-6 h-6 rounded-lg bg-amber-500/15 text-amber-500 flex items-center justify-center shrink-0 mt-0.5 font-bold">
                  ✓
                </div>
                <div>
                  <h4 className="text-sm font-bold text-foreground">
                    Know when
                  </h4>
                  <p className="text-xs text-muted-foreground">
                    Automated push reminders arrive at 8:00 AM on the scheduled member&apos;s duty day.
                  </p>
                </div>
              </div>
            </div>
          </motion.div>

          {/* Right Visual Card (Interactive Shopping & Duty Planner) */}
          <motion.div
            initial={{ opacity: 0, x: 20 }}
            whileInView={{ opacity: 1, x: 0 }}
            viewport={{ once: true }}
            transition={{ duration: 0.5 }}
            className="lg:col-span-6"
          >
            <div className="rounded-2xl sm:rounded-3xl border border-white/10 bg-card p-6 sm:p-8 shadow-[0_20px_60px_rgba(0,0,0,0.35)] relative overflow-hidden backdrop-blur-xl">
              {/* Top Duty Assignment Card */}
              <div className="p-4 rounded-xl bg-secondary/70 border border-border/60 mb-6 flex flex-col sm:flex-row sm:items-center justify-between gap-3">
                <div className="flex items-center gap-3">
                  <div className="w-10 h-10 rounded-xl bg-amber-500/15 text-amber-500 flex items-center justify-center font-bold">
                    <UserCheck className="w-5 h-5" />
                  </div>
                  <div>
                    <span className="text-[10px] text-muted-foreground uppercase font-bold tracking-wider">
                      Upcoming Bazar Duty
                    </span>
                    <h4 className="text-sm font-bold text-foreground">
                      Kawser Ahmed
                    </h4>
                  </div>
                </div>

                <div className="flex items-center gap-2">
                  <div className="text-right text-xs">
                    <span className="text-amber-500 font-bold block">18 August</span>
                    <span className="text-[10px] text-muted-foreground">Tomorrow 8:00 AM</span>
                  </div>
                  <div className="p-2 rounded-lg bg-amber-500/10 text-amber-500">
                    <Bell className="w-4 h-4" />
                  </div>
                </div>
              </div>

              {/* Shopping Checklist */}
              <div className="space-y-3">
                <div className="flex items-center justify-between">
                  <span className="text-xs font-bold text-foreground flex items-center gap-1.5">
                    <ShoppingBag className="w-4 h-4 text-[#8B3DFF]" /> Live Mess Shopping List
                  </span>
                  <span className="text-[11px] text-muted-foreground font-medium">
                    Tap to check off
                  </span>
                </div>

                <div className="space-y-2">
                  {items.map((item, index) => (
                    <button
                      key={index}
                      onClick={() => toggleItem(index)}
                      className={`w-full p-3 rounded-xl border flex items-center justify-between text-left transition-all cursor-pointer text-xs ${
                        item.checked
                          ? "bg-secondary/40 border-border/40 text-muted-foreground"
                          : "bg-background border-border/70 text-foreground font-semibold shadow-sm"
                      }`}
                    >
                      <div className="flex items-center gap-2.5">
                        <span
                          className={`w-4 h-4 rounded-md flex items-center justify-center text-[10px] border ${
                            item.checked
                              ? "bg-emerald-500 border-emerald-500 text-white"
                              : "border-border bg-background"
                          }`}
                        >
                          {item.checked && "✓"}
                        </span>
                        <span className={item.checked ? "line-through opacity-70" : ""}>
                          {item.name}
                        </span>
                      </div>
                      <span className="text-[10px] text-muted-foreground font-mono">
                        {item.checked ? "Done" : "Pending"}
                      </span>
                    </button>
                  ))}
                </div>
              </div>
            </div>
          </motion.div>
        </div>
      </div>
    </section>
  );
}
