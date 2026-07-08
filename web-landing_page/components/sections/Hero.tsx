"use client";

import { Button } from "@/components/ui/button";
import { motion } from "framer-motion";
import { ArrowRight, PlayCircle } from "lucide-react";
import Image from "next/image";

export function Hero() {
  return (
    <section className="relative pt-32 pb-20 lg:pt-48 lg:pb-32 overflow-hidden">
      {/* Background Decorative Elements */}
      <div className="absolute top-0 left-1/2 -translate-x-1/2 w-full max-w-7xl h-full -z-10">
        <div className="absolute top-[-10%] left-[-10%] w-[40%] h-[40%] bg-primary/20 blur-[120px] rounded-full opacity-50" />
        <div className="absolute bottom-[10%] right-[-10%] w-[40%] h-[40%] bg-primary/10 blur-[120px] rounded-full opacity-50" />
      </div>

      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 text-center">
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.5 }}
        >
          <span className="inline-flex items-center px-4 py-1.5 rounded-full text-sm font-medium bg-primary/10 text-primary border border-primary/20 mb-8">
            মেস ম্যানেজমেন্ট এখন একদম সহজ ✨
          </span>
          <h1 className="text-4xl md:text-6xl lg:text-7xl font-bold tracking-tight mb-6">
            Stop Fighting Over <br />
            <span className="bg-clip-text text-transparent bg-gradient-to-r from-primary to-primary/60">
              Meal Costs.
            </span>
          </h1>
          <p className="max-w-2xl mx-auto text-lg md:text-xl text-muted-foreground mb-10 leading-relaxed">
            ব্যাসেলর মেসের হিসাব-নিকাশ এখন পানির মতো সহজ। 
            <span className="text-foreground font-medium"> Meal tracking </span> 
            থেকে শুরু করে 
            <span className="text-foreground font-medium"> automatic balance calculation </span> 
            - সব হবে এক জায়গায়।
          </p>
          
          <div className="flex flex-col sm:flex-row items-center justify-center gap-4">
            <Button size="lg" className="rounded-full px-8 h-14 text-lg group">
              Get Started for Free
              <ArrowRight className="ml-2 h-5 w-5 group-hover:translate-x-1 transition-transform" />
            </Button>
            <Button size="lg" variant="outline" className="rounded-full px-8 h-14 text-lg">
              <PlayCircle className="mr-2 h-5 w-5" />
              Watch Demo
            </Button>
          </div>
        </motion.div>

        {/* Dashboard Preview */}
        <motion.div
          initial={{ opacity: 0, y: 40 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.8, delay: 0.2 }}
          className="mt-20 relative max-w-5xl mx-auto group"
        >
          {/* Animated Glow behind dashboard */}
          <div className="absolute -inset-1 bg-gradient-to-r from-primary to-purple-600 rounded-2xl blur opacity-25 group-hover:opacity-40 transition duration-1000 group-hover:duration-200"></div>
          
          <div className="relative rounded-2xl border border-border/50 bg-background/80 backdrop-blur-xl overflow-hidden shadow-2xl">
             {/* Mock Dashboard UI */}
             <div className="aspect-[16/10] bg-zinc-950/40 flex flex-col">
                <div className="h-14 border-b border-white/5 flex items-center px-6 justify-between bg-white/5">
                   <div className="flex items-center gap-4">
                      <div className="flex gap-2">
                         <div className="w-3 h-3 rounded-full bg-red-500/40" />
                         <div className="w-3 h-3 rounded-full bg-yellow-500/40" />
                         <div className="w-3 h-3 rounded-full bg-green-500/40" />
                      </div>
                      <div className="h-6 w-px bg-white/10 mx-2" />
                      <div className="h-5 w-32 bg-white/10 rounded-md" />
                   </div>
                   <div className="flex gap-3">
                      <div className="h-8 w-8 rounded-full bg-white/5 border border-white/10" />
                      <div className="h-8 w-24 bg-primary/20 rounded-full border border-primary/30" />
                   </div>
                </div>
                
                <div className="flex-1 p-8 grid grid-cols-12 gap-6">
                   {/* Left Stats */}
                   <div className="col-span-8 space-y-6">
                      <div className="grid grid-cols-3 gap-4">
                         {[
                           { label: "Total Meals", value: "245.5", color: "text-blue-400" },
                           { label: "Mess Balance", value: "৳12,450", color: "text-emerald-400" },
                           { label: "Meal Rate", value: "৳45.20", color: "text-orange-400" }
                         ].map((stat, i) => (
                           <div key={i} className="p-4 rounded-xl bg-white/5 border border-white/10 hover:bg-white/[0.08] transition-colors">
                              <p className="text-[10px] uppercase tracking-wider text-muted-foreground mb-1">{stat.label}</p>
                              <p className={`text-xl font-bold ${stat.color}`}>{stat.value}</p>
                           </div>
                         ))}
                      </div>
                      
                      {/* Main Chart Area Mockup */}
                      <div className="h-48 bg-white/5 rounded-2xl border border-white/10 p-6 relative overflow-hidden">
                         <div className="flex justify-between items-center mb-6">
                            <div className="h-4 w-32 bg-white/10 rounded" />
                            <div className="h-4 w-16 bg-white/5 rounded" />
                         </div>
                         {/* Fake Chart Lines */}
                         <div className="absolute inset-x-0 bottom-0 h-24 flex items-end px-6 gap-2">
                            {[40, 70, 45, 90, 65, 80, 55, 75, 40, 85, 60, 95].map((h, i) => (
                              <motion.div 
                                key={i}
                                initial={{ height: 0 }}
                                animate={{ height: `${h}%` }}
                                transition={{ delay: 0.5 + i * 0.05, duration: 0.8 }}
                                className="flex-1 bg-gradient-to-t from-primary/40 to-primary/10 rounded-t-sm"
                              />
                            ))}
                         </div>
                      </div>
                   </div>
                   
                   {/* Right Feed */}
                   <div className="col-span-4 bg-white/5 rounded-2xl border border-white/10 p-5 space-y-4">
                      <div className="h-4 w-24 bg-white/10 rounded mb-6" />
                      {[1, 2, 3, 4].map((i) => (
                        <div key={i} className="flex gap-3 items-center">
                           <div className="w-8 h-8 rounded-full bg-white/10 border border-white/10" />
                           <div className="space-y-1.5 flex-1">
                              <div className="h-3 w-full bg-white/10 rounded-sm" />
                              <div className="h-2 w-2/3 bg-white/5 rounded-sm" />
                           </div>
                        </div>
                      ))}
                   </div>
                </div>
             </div>
             {/* Gradient Overlay for that premium look */}
             <div className="absolute inset-0 pointer-events-none bg-gradient-to-tr from-primary/5 via-transparent to-purple-500/5" />
          </div>
          
          {/* Floating dynamic badges */}
          <motion.div 
            animate={{ y: [0, -10, 0] }}
            transition={{ repeat: Infinity, duration: 3, ease: "easeInOut" }}
            className="absolute -top-10 -right-10 hidden md:block"
          >
            <div className="glass p-5 rounded-2xl shadow-2xl border-primary/20 backdrop-blur-2xl">
               <div className="flex items-center gap-4">
                  <div className="w-12 h-12 rounded-full bg-emerald-500/20 flex items-center justify-center text-emerald-400">
                     <span className="text-xl font-bold">৳</span>
                  </div>
                  <div>
                     <p className="text-xs text-muted-foreground uppercase tracking-widest">New Deposit</p>
                     <p className="text-lg font-bold">৳2,000.00</p>
                  </div>
               </div>
            </div>
          </motion.div>
        </motion.div>
      </div>
    </section>
  );
}
