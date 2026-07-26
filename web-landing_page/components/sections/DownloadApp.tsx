"use client";

import { motion } from "framer-motion";
import { Calendar, DollarSign } from "lucide-react";

export function DownloadApp() {
  return (
    <section className="py-20 lg:py-28 relative">
      <div className="max-w-6xl mx-auto px-5 sm:px-8">
        <div className="grid lg:grid-cols-2 gap-12 lg:gap-16 items-center">
          {/* Text */}
          <motion.div
            initial={{ opacity: 0, x: -20 }}
            whileInView={{ opacity: 1, x: 0 }}
            viewport={{ once: true }}
            transition={{ duration: 0.5 }}
            className="space-y-5"
          >
            <span className="text-[11px] font-bold uppercase tracking-widest text-primary">
              Mobile App
            </span>
            <h2 className="text-3xl sm:text-4xl font-extrabold tracking-[-0.02em] leading-[1.1]">
              Your mess life,
              <br />
              <span className="text-primary">in your pocket.</span>
            </h2>
            <p className="text-muted-foreground text-[15px] leading-relaxed max-w-md">
              Download BachelorPoints and manage your mess from anywhere. Available on both
              Android and iOS — real-time sync, offline-ready meal entry, and instant
              notifications.
            </p>

            <div className="flex flex-wrap gap-3 pt-2">
              {/* App Store */}
              <a
                href="#"
                className="flex items-center gap-3 bg-foreground text-background px-5 py-3 rounded-lg font-medium transition-all hover:opacity-90"
              >
                <svg className="w-5 h-5 fill-current" viewBox="0 0 24 24">
                  <path d="M18.71 19.5c-.83 1.24-1.71 2.45-3.05 2.47-1.34.03-1.77-.79-3.29-.79-1.53 0-2 .77-3.27.82-1.31.05-2.3-1.32-3.14-2.53C4.25 17 2.94 12.45 4.7 9.39c.87-1.52 2.43-2.48 4.12-2.51 1.28-.02 2.5.87 3.29.87.78 0 2.26-1.07 3.8-.91.65.03 2.47.26 3.64 1.98-.09.06-2.17 1.28-2.15 3.81.03 3.02 2.65 4.03 2.68 4.04-.03.07-.42 1.44-1.38 2.83M13 3.5c.73-.83 1.94-1.46 2.94-1.5.13 1.17-.34 2.35-1.04 3.19-.69.85-1.83 1.51-2.95 1.42-.15-1.15.41-2.35 1.05-3.11z" />
                </svg>
                <div className="text-left">
                  <p className="text-[9px] uppercase font-bold opacity-70 leading-none">
                    Download on the
                  </p>
                  <p className="text-[13px] font-bold leading-tight">App Store</p>
                </div>
              </a>

              {/* Play Store */}
              <a
                href="#"
                className="flex items-center gap-3 bg-secondary border border-border/60 text-foreground px-5 py-3 rounded-lg font-medium transition-all hover:bg-secondary/80"
              >
                <svg className="w-5 h-5 fill-current" viewBox="0 0 24 24">
                  <path d="M3.609 1.814L13.792 12 3.61 22.186a2.156 2.156 0 01-.453-1.425V3.239c0-.55.166-1.04.452-1.425zm1.18-.553l12.186 6.94-3.183 3.2L4.79 1.261zm12.186 14.54l-12.186 6.94 9.003-9.04 3.183 3.2zm1.037-1.037l4.037-2.3c.7-.4 1.1-.9 1.1-1.6s-.4-1.2-1.1-1.6l-4.037-2.3-3.41 3.43 3.41 3.47z" />
                </svg>
                <div className="text-left">
                  <p className="text-[9px] uppercase font-bold opacity-50 leading-none">
                    Get it on
                  </p>
                  <p className="text-[13px] font-bold leading-tight">Google Play</p>
                </div>
              </a>
            </div>
          </motion.div>

          {/* Phone mockup */}
          <motion.div
            initial={{ opacity: 0, scale: 0.96 }}
            whileInView={{ opacity: 1, scale: 1 }}
            viewport={{ once: true }}
            transition={{ duration: 0.5 }}
            className="relative flex justify-center"
          >
            <div className="relative mx-auto border-[6px] border-neutral-800 rounded-[2.5rem] bg-neutral-950 w-[240px] h-[490px] shadow-2xl overflow-hidden p-2.5">
              {/* Dynamic island */}
              <div className="absolute top-2 left-1/2 -translate-x-1/2 w-24 h-3.5 bg-neutral-800 rounded-full z-20" />

              {/* Screen */}
              <div className="w-full h-full rounded-[1.85rem] bg-background border border-neutral-900/60 p-4 flex flex-col justify-between text-[10px] text-foreground font-sans">
                <div>
                  <div className="flex justify-between items-center mt-3 pb-3 border-b border-border/40">
                    <div>
                      <span className="text-muted-foreground block text-[8px] font-medium">
                        Mess Dashboard
                      </span>
                      <span className="font-extrabold text-foreground text-xs">
                        Good morning, Arif!
                      </span>
                    </div>
                    <div className="w-7 h-7 rounded-full bg-primary/10 border border-primary/15 flex items-center justify-center font-bold text-primary text-[10px]">
                      AR
                    </div>
                  </div>
                  <div className="mt-4 space-y-2">
                    <p className="text-[9px] text-muted-foreground font-bold uppercase tracking-wider">
                      Recent:
                    </p>
                    <div className="bg-card border border-border/40 rounded-lg p-2.5 flex gap-2 items-center">
                      <div className="w-5 h-5 rounded-full bg-emerald-500/10 flex items-center justify-center shrink-0">
                        <Calendar className="w-3 h-3 text-emerald-500" />
                      </div>
                      <div>
                        <span className="font-bold text-foreground block">
                          Zahid updated meal portion
                        </span>
                        <span className="text-[8px] text-muted-foreground">1:30 PM</span>
                      </div>
                    </div>
                    <div className="bg-card border border-border/40 rounded-lg p-2.5 flex gap-2 items-center">
                      <div className="w-5 h-5 rounded-full bg-rose-500/10 flex items-center justify-center shrink-0">
                        <DollarSign className="w-3 h-3 text-rose-500" />
                      </div>
                      <div>
                        <span className="font-bold text-foreground block">
                          New expense: ৳540 (oil & potatoes)
                        </span>
                        <span className="text-[8px] text-muted-foreground">10:15 AM</span>
                      </div>
                    </div>
                  </div>
                </div>
                <div className="p-3 bg-muted/50 rounded-xl border border-border/40 text-center">
                  <span className="font-bold block mb-0.5">BachelorPoints v2.0</span>
                  <span className="text-[8px] text-muted-foreground block">
                    Smart mess calculation active
                  </span>
                </div>
              </div>
            </div>

            {/* Floating sync badge */}
            <div className="absolute top-1/4 -left-4 bg-card/90 backdrop-blur-sm px-3 py-2 rounded-lg border border-border/40 shadow-lg flex items-center gap-2">
              <span className="w-2 h-2 rounded-full bg-emerald-500 animate-pulse" />
              <span className="text-[10px] font-bold text-foreground">Real-time sync</span>
            </div>
          </motion.div>
        </div>
      </div>
    </section>
  );
}
