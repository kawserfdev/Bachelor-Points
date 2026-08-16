"use client";

import { motion } from "framer-motion";
import { CheckCircle2, Bell } from "lucide-react";

export function DownloadApp() {
  return (
    <section className="py-20 lg:py-28 relative">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div className="grid lg:grid-cols-12 gap-12 lg:gap-16 items-center">
          {/* Left Text & Store Badges */}
          <motion.div
            initial={{ opacity: 0, x: -20 }}
            whileInView={{ opacity: 1, x: 0 }}
            viewport={{ once: true }}
            transition={{ duration: 0.5 }}
            className="lg:col-span-6 space-y-6"
          >
            <span className="text-xs font-bold uppercase tracking-widest text-[#8B3DFF] bg-[#8B3DFF]/10 px-3.5 py-1.5 rounded-full border border-[#8B3DFF]/20">
              Cross-Platform Ready
            </span>

            <h2 className="text-3xl sm:text-4xl lg:text-5xl font-extrabold tracking-tight text-foreground leading-[1.12]">
              Your Mess Life,
              <br />
              <span className="bg-gradient-to-r from-[#8B3DFF] to-[#A855F7] bg-clip-text text-transparent">
                Always in Your Pocket.
              </span>
            </h2>

            <p className="text-muted-foreground text-base sm:text-lg leading-relaxed font-normal">
              Manage your mess from anywhere — whether you&apos;re in the university classroom,
              office commute, or dining table. Available across Android, iOS, and Modern Web.
            </p>

            <div className="space-y-3">
              <div className="flex items-center gap-3 text-xs sm:text-sm font-semibold text-foreground">
                <CheckCircle2 className="w-4 h-4 text-emerald-500 shrink-0" />
                <span>Instant push notifications on meal updates & bazar schedules</span>
              </div>
              <div className="flex items-center gap-3 text-xs sm:text-sm font-semibold text-foreground">
                <CheckCircle2 className="w-4 h-4 text-emerald-500 shrink-0" />
                <span>Offline-ready meal entry with auto cloud sync</span>
              </div>
              <div className="flex items-center gap-3 text-xs sm:text-sm font-semibold text-foreground">
                <CheckCircle2 className="w-4 h-4 text-emerald-500 shrink-0" />
                <span>Lightning-fast performance optimized for mobile data</span>
              </div>
            </div>

            {/* Store Badges */}
            <div className="flex flex-wrap items-center gap-3.5 pt-4">
              <a
                href="/app/login"
                className="flex items-center gap-3 bg-secondary hover:bg-secondary/80 border border-border/70 text-foreground px-5 py-3 rounded-xl transition-all shadow-sm"
              >
                <svg className="w-6 h-6 fill-current" viewBox="0 0 24 24">
                  <path d="M18.71 19.5c-.83 1.24-1.71 2.45-3.05 2.47-1.34.03-1.77-.79-3.29-.79-1.53 0-2 .77-3.27.82-1.31.05-2.3-1.32-3.14-2.53C4.25 17 2.94 12.45 4.7 9.39c.87-1.52 2.43-2.48 4.12-2.51 1.28-.02 2.5.87 3.29.87.78 0 2.26-1.07 3.8-.91.65.03 2.47.26 3.64 1.98-.09.06-2.17 1.28-2.15 3.81.03 3.02 2.65 4.03 2.68 4.04-.03.07-.42 1.44-1.38 2.83M13 3.5c.73-.83 1.94-1.46 2.94-1.5.13 1.17-.34 2.35-1.04 3.19-.69.85-1.83 1.51-2.95 1.42-.15-1.15.41-2.35 1.05-3.11z" />
                </svg>
                <div className="text-left">
                  <span className="text-[10px] uppercase font-bold text-muted-foreground block leading-tight">
                    Download on the
                  </span>
                  <span className="text-sm font-bold leading-tight">App Store</span>
                </div>
              </a>

              <a
                href="/app/login"
                className="flex items-center gap-3 bg-secondary hover:bg-secondary/80 border border-border/70 text-foreground px-5 py-3 rounded-xl transition-all shadow-sm"
              >
                <svg className="w-6 h-6 fill-current" viewBox="0 0 24 24">
                  <path d="M3.609 1.814L13.792 12 3.61 22.186a2.156 2.156 0 01-.453-1.425V3.239c0-.55.166-1.04.452-1.425zm1.18-.553l12.186 6.94-3.183 3.2L4.79 1.261zm12.186 14.54l-12.186 6.94 9.003-9.04 3.183 3.2zm1.037-1.037l4.037-2.3c.7-.4 1.1-.9 1.1-1.6s-.4-1.2-1.1-1.6l-4.037-2.3-3.41 3.43 3.41 3.47z" />
                </svg>
                <div className="text-left">
                  <span className="text-[10px] uppercase font-bold text-muted-foreground block leading-tight">
                    Get it on
                  </span>
                  <span className="text-sm font-bold leading-tight">Google Play</span>
                </div>
              </a>
            </div>
          </motion.div>

          {/* Right Mobile Mockup */}
          <motion.div
            initial={{ opacity: 0, x: 20 }}
            whileInView={{ opacity: 1, x: 0 }}
            viewport={{ once: true }}
            transition={{ duration: 0.5 }}
            className="lg:col-span-6 flex justify-center relative"
          >
            {/* Phone Frame */}
            <div className="relative mx-auto w-[270px] sm:w-[300px] h-[540px] sm:h-[580px] rounded-[3rem] border-[8px] border-neutral-900 bg-neutral-950 shadow-2xl p-2.5 overflow-hidden">
              {/* Dynamic Island */}
              <div className="absolute top-3 left-1/2 -translate-x-1/2 w-24 h-4 bg-neutral-900 rounded-full z-20" />

              {/* Mobile Screen Content */}
              <div className="w-full h-full rounded-[2.25rem] bg-background border border-neutral-900 p-4 flex flex-col justify-between text-xs text-foreground font-sans pt-7">
                <div className="space-y-4">
                  {/* Top bar in phone */}
                  <div className="flex items-center justify-between pb-3 border-b border-border/40">
                    <div>
                      <span className="text-[10px] text-muted-foreground font-semibold block">
                        Dhanmondi Mess
                      </span>
                      <span className="font-extrabold text-sm text-foreground">
                        Today&apos;s Meal Status
                      </span>
                    </div>
                    <span className="w-8 h-8 rounded-full bg-[#8B3DFF]/15 text-[#8B3DFF] flex items-center justify-center font-bold text-xs">
                      KA
                    </span>
                  </div>

                  {/* Meal Count Card */}
                  <div className="p-3.5 rounded-xl bg-secondary/50 border border-border/50 space-y-2">
                    <div className="flex items-center justify-between">
                      <span className="font-bold text-foreground">Your Portions</span>
                      <span className="text-[10px] text-emerald-500 font-bold bg-emerald-500/10 px-2 py-0.5 rounded">
                        2.5 Total
                      </span>
                    </div>
                    <div className="grid grid-cols-3 gap-1.5 text-center text-[11px]">
                      <div className="p-1.5 rounded bg-background border border-border/40 font-medium">
                        Breakfast: 0.5
                      </div>
                      <div className="p-1.5 rounded bg-background border border-border/40 font-medium">
                        Lunch: 1.0
                      </div>
                      <div className="p-1.5 rounded bg-background border border-border/40 font-medium">
                        Dinner: 1.0
                      </div>
                    </div>
                  </div>

                  {/* Notification in phone */}
                  <div className="p-3 rounded-xl bg-[#8B3DFF]/10 border border-[#8B3DFF]/20 space-y-1">
                    <div className="flex items-center gap-1.5 text-[#8B3DFF] font-bold text-[11px]">
                      <Bell className="w-3.5 h-3.5" />
                      <span>Bazar Duty Tomorrow</span>
                    </div>
                    <p className="text-[10px] text-muted-foreground">
                      Assigned to Kawser Ahmed • Checklist ready
                    </p>
                  </div>
                </div>

                {/* Bottom Bar in phone */}
                <div className="p-3 rounded-xl bg-secondary/70 border border-border/50 text-center">
                  <span className="text-[11px] font-bold text-foreground block">
                    BachelorPoints v2.4
                  </span>
                  <span className="text-[9px] text-muted-foreground">
                    Cloud Synced • Offline Protected
                  </span>
                </div>
              </div>
            </div>

            {/* Floating Badge */}
            <div className="absolute top-1/3 -left-4 sm:-left-6 bg-card/95 border border-white/15 px-3.5 py-2.5 rounded-xl shadow-xl backdrop-blur-md flex items-center gap-2">
              <span className="w-2.5 h-2.5 rounded-full bg-emerald-500 animate-pulse" />
              <span className="text-xs font-bold text-foreground">Live Cloud Sync</span>
            </div>
          </motion.div>
        </div>
      </div>
    </section>
  );
}
