"use client";

import { motion } from "framer-motion";
import { Apple, PlayCircle } from "lucide-react";

export function DownloadApp() {
  return (
    <section className="py-24 relative overflow-hidden bg-zinc-950">
      {/* Abstract Background Shapes */}
      <div className="absolute top-0 left-0 w-full h-full overflow-hidden -z-0">
        <div className="absolute top-[-20%] right-[-10%] w-[60%] h-[60%] bg-primary/20 blur-[120px] rounded-full" />
        <div className="absolute bottom-[-20%] left-[-10%] w-[60%] h-[60%] bg-purple-500/10 blur-[120px] rounded-full" />
      </div>

      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 relative z-10">
        <div className="grid grid-cols-1 lg:grid-cols-2 gap-16 items-center">
          <motion.div
            initial={{ opacity: 0, x: -50 }}
            whileInView={{ opacity: 1, x: 0 }}
            viewport={{ once: true }}
            className="space-y-8"
          >
            <h2 className="text-4xl md:text-6xl font-bold text-white leading-tight">
              Manage Your Mess <br />
              <span className="bg-clip-text text-transparent bg-gradient-to-r from-primary to-purple-400">
                On the Go.
              </span>
            </h2>
            <p className="text-zinc-400 text-lg md:text-xl max-w-lg leading-relaxed">
              ডাউনলোড করুন BachelorPoints অ্যাপ এবং আপনার হাতের মুঠোয় রাখুন মেসের যাবতীয় হিসাব। অ্যান্ড্রয়েড এবং আইওএস - দুই প্ল্যাটফর্মেই আমরা আছি।
            </p>

            <div className="flex flex-wrap gap-4 pt-4">
              {/* App Store Button */}
              <motion.a
                href="#"
                whileHover={{ scale: 1.05 }}
                whileTap={{ scale: 0.95 }}
                className="flex items-center gap-3 bg-white text-black px-8 py-4 rounded-2xl font-bold transition-all hover:shadow-[0_0_20px_rgba(255,255,255,0.3)]"
              >
                <Apple className="w-8 h-8" />
                <div className="text-left">
                  <p className="text-[10px] uppercase font-medium leading-none opacity-60">Download on the</p>
                  <p className="text-xl font-bold leading-tight">App Store</p>
                </div>
              </motion.a>

              {/* Play Store Button */}
              <motion.a
                href="#"
                whileHover={{ scale: 1.05 }}
                whileTap={{ scale: 0.95 }}
                className="flex items-center gap-3 bg-zinc-800 text-white border border-zinc-700 px-8 py-4 rounded-2xl font-bold transition-all hover:bg-zinc-700 hover:shadow-[0_0_20px_rgba(99,102,241,0.2)]"
              >
                <svg className="w-8 h-8 fill-current" viewBox="0 0 24 24">
                  <path d="M3.609 1.814L13.792 12 3.61 22.186a2.156 2.156 0 01-.453-1.425V3.239c0-.55.166-1.04.452-1.425zm1.18-.553l12.186 6.94-3.183 3.2L4.79 1.261zm12.186 14.54l-12.186 6.94 9.003-9.04 3.183 3.2zm1.037-1.037l4.037-2.3c.7-.4 1.1-.9 1.1-1.6s-.4-1.2-1.1-1.6l-4.037-2.3-3.41 3.43 3.41 3.47z" />
                </svg>
                <div className="text-left">
                  <p className="text-[10px] uppercase font-medium leading-none opacity-60">Get it on</p>
                  <p className="text-xl font-bold leading-tight">Google Play</p>
                </div>
              </motion.a>
            </div>
          </motion.div>

          <motion.div
            initial={{ opacity: 0, scale: 0.8, rotate: 5 }}
            whileInView={{ opacity: 1, scale: 1, rotate: 0 }}
            viewport={{ once: true }}
            transition={{ duration: 1, type: "spring" }}
            className="relative"
          >
            {/* Phone Mockup */}
            <div className="relative mx-auto border-8 border-zinc-800 rounded-[3rem] bg-zinc-900 w-[280px] h-[580px] shadow-2xl overflow-hidden">
              <div className="absolute top-0 left-1/2 -translate-x-1/2 w-32 h-6 bg-zinc-800 rounded-b-2xl z-20" />
              <div className="p-4 space-y-6">
                <div className="flex justify-between items-center pt-8">
                  <div className="h-4 w-24 bg-white/10 rounded" />
                  <div className="w-10 h-10 rounded-full bg-primary/20" />
                </div>
                <div className="h-32 bg-white/5 rounded-2xl border border-white/10 p-4">
                  <div className="h-4 w-1/2 bg-white/10 rounded mb-4" />
                  <div className="flex gap-2">
                    <div className="h-10 w-10 rounded-full bg-emerald-500/20" />
                    <div className="space-y-2 flex-1">
                      <div className="h-4 w-full bg-white/10 rounded" />
                      <div className="h-3 w-2/3 bg-white/5 rounded" />
                    </div>
                  </div>
                </div>
                <div className="grid grid-cols-2 gap-4">
                  <div className="h-24 bg-white/5 rounded-2xl" />
                  <div className="h-24 bg-white/5 rounded-2xl" />
                </div>
                <div className="h-48 bg-white/5 rounded-2xl" />
              </div>
              {/* Inner Gradient */}
              <div className="absolute inset-0 bg-gradient-to-t from-primary/10 via-transparent to-transparent pointer-events-none" />
            </div>

            {/* Decorative Floating Elements */}
            <motion.div
              animate={{ y: [0, -20, 0] }}
              transition={{ repeat: Infinity, duration: 4 }}
              className="absolute top-1/4 -left-10 glass p-4 rounded-2xl shadow-2xl border-white/10"
            >
              <div className="flex items-center gap-2">
                <div className="w-2 h-2 rounded-full bg-green-500" />
                <span className="text-xs text-white">Live Updates</span>
              </div>
            </motion.div>
          </motion.div>
        </div>
      </div>
    </section>
  );
}
