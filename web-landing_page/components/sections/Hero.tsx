"use client";

import { Button } from "@/components/ui/button";
import { ArrowRight, PlayCircle } from "lucide-react";

export function Hero() {
  return (
    <section className="relative pt-28 pb-20 lg:pt-36 lg:pb-28 overflow-hidden">
      {/* Subtle grid texture */}
      <div className="absolute inset-0 subtle-grid opacity-60 pointer-events-none" />

      {/* Soft ambient light - top left */}
      <div className="absolute top-0 left-0 w-[500px] h-[400px] bg-primary/[0.03] blur-[100px] rounded-full pointer-events-none" />

      <div className="max-w-6xl mx-auto px-5 sm:px-8 relative">
        <div className="grid lg:grid-cols-12 gap-12 lg:gap-8 items-start">
          {/* Left: Copy */}
          <div className="lg:col-span-5 pt-4 lg:pt-8">
            <div className="inline-flex items-center gap-2 px-3 py-1.5 rounded-full bg-primary/[0.08] border border-primary/10 mb-6">
              <span className="w-1.5 h-1.5 rounded-full bg-primary animate-pulse" />
              <span className="text-[11px] font-semibold text-primary tracking-wide">
                Mess management, simplified
              </span>
            </div>

            <h1 className="text-[2.75rem] sm:text-5xl lg:text-[3.5rem] font-extrabold tracking-[-0.03em] leading-[1.08] mb-5 text-balance">
              Stop fighting
              <br />
              over meal costs.
            </h1>

            <p className="text-muted-foreground text-[15px] sm:text-base leading-relaxed max-w-md mb-8">
              Bachelor mess life, handled digitally. From meal tracking to
              automatic balance calculations — everything in one place, so you
              never argue about money again.
            </p>

            <div className="flex flex-wrap items-center gap-3 mb-8">
              <Button
                asChild
                size="lg"
                className="rounded-lg px-6 h-11 text-[14px] font-semibold bg-primary hover:bg-primary/90 text-primary-foreground shadow-sm"
              >
                <a href="/app/login">
                  Get Started for Free
                  <ArrowRight className="ml-1.5 h-4 w-4" />
                </a>
              </Button>
              <Button
                asChild
                size="lg"
                variant="ghost"
                className="rounded-lg px-5 h-11 text-[14px] font-medium text-muted-foreground hover:text-foreground"
              >
                <a href="#how-it-works">
                  <PlayCircle className="mr-1.5 h-4 w-4" />
                  See How It Works
                </a>
              </Button>
            </div>

            {/* Trust indicators */}
            <div className="flex items-center gap-4 text-[12px] text-muted-foreground">
              <div className="flex items-center gap-1.5">
                <svg className="w-3.5 h-3.5 text-primary" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round">
                  <path d="M22 11.08V12a10 10 0 1 1-5.93-9.14" />
                  <polyline points="22 4 12 14.01 9 11.01" />
                </svg>
                <span>Free to start</span>
              </div>
              <div className="w-px h-3 bg-border" />
              <div className="flex items-center gap-1.5">
                <svg className="w-3.5 h-3.5 text-primary" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round">
                  <path d="M22 11.08V12a10 10 0 1 1-5.93-9.14" />
                  <polyline points="22 4 12 14.01 9 11.01" />
                </svg>
                <span>No credit card needed</span>
              </div>
              <div className="w-px h-3 bg-border hidden sm:block" />
              <div className="items-center gap-1.5 hidden sm:flex">
                <svg className="w-3.5 h-3.5 text-primary" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round">
                  <path d="M22 11.08V12a10 10 0 1 1-5.93-9.14" />
                  <polyline points="22 4 12 14.01 9 11.01" />
                </svg>
                <span>Available on iOS & Android</span>
              </div>
            </div>
          </div>

          {/* Right: Dashboard Preview */}
          <div className="lg:col-span-7 relative">
            <DashboardMockup />
          </div>
        </div>
      </div>
    </section>
  );
}

function DashboardMockup() {
  return (
    <div className="relative">
      {/* Subtle shadow underneath */}
      <div className="absolute -inset-1 bg-gradient-to-b from-primary/[0.06] to-transparent rounded-2xl blur-xl pointer-events-none" />

      <div className="relative rounded-xl border border-border/60 bg-card overflow-hidden shadow-[0_8px_30px_rgba(0,0,0,0.06)] dark:shadow-[0_8px_30px_rgba(0,0,0,0.2)]">
        {/* Browser chrome */}
        <div className="h-10 border-b border-border/40 flex items-center px-4 gap-3 bg-muted/30">
          <div className="flex gap-1.5">
            <div className="w-2.5 h-2.5 rounded-full bg-border/70" />
            <div className="w-2.5 h-2.5 rounded-full bg-border/70" />
            <div className="w-2.5 h-2.5 rounded-full bg-border/70" />
          </div>
          <div className="flex-1 flex justify-center">
            <div className="flex items-center gap-2 bg-background/80 px-3 py-1 rounded-md border border-border/50 text-[11px] text-muted-foreground font-medium">
              <svg className="w-3 h-3" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
                <rect x="3" y="11" width="18" height="11" rx="2" ry="2" />
                <path d="M7 11V7a5 5 0 0 1 10 0v4" />
              </svg>
              bachelorpoints.com/dashboard
            </div>
          </div>
          <div className="w-16" />
        </div>

        {/* Dashboard body */}
        <div className="p-5 sm:p-6 space-y-5">
          {/* Top bar */}
          <div className="flex items-center justify-between">
            <div>
              <p className="text-[11px] text-muted-foreground font-medium">Dashboard</p>
              <p className="text-sm font-bold text-foreground">July 2026 — Mess Overview</p>
            </div>
            <div className="flex items-center gap-2">
              <span className="px-2.5 py-1 rounded-md bg-primary/[0.08] border border-primary/10 text-[11px] font-semibold text-primary">
                Active
              </span>
              <div className="w-7 h-7 rounded-full bg-primary/10 border border-primary/15 flex items-center justify-center text-[10px] font-bold text-primary">
                AP
              </div>
            </div>
          </div>

          {/* Stat cards */}
          <div className="grid grid-cols-3 gap-3">
            {[
              { label: "Total Meals", value: "245.5", sub: "+12.2% vs last month", accent: "text-primary" },
              { label: "Mess Balance", value: "৳12,450", sub: "4 members pending", accent: "text-emerald-600 dark:text-emerald-400" },
              { label: "Meal Rate", value: "৳45.20", sub: "Updated 10m ago", accent: "text-accent" },
            ].map((s) => (
              <div key={s.label} className="p-3.5 rounded-lg bg-muted/40 border border-border/30">
                <p className="text-[10px] font-semibold text-muted-foreground uppercase tracking-wider mb-1.5">
                  {s.label}
                </p>
                <p className={`text-lg font-extrabold tracking-tight ${s.accent}`}>
                  {s.value}
                </p>
                <p className="text-[10px] text-muted-foreground/70 mt-1">{s.sub}</p>
              </div>
            ))}
          </div>

          {/* Chart area */}
          <div className="rounded-lg bg-muted/20 border border-border/30 p-4 relative overflow-hidden">
            <div className="flex justify-between items-center mb-4">
              <div>
                <p className="text-[12px] font-bold text-foreground">Meal Intake Analytics</p>
                <p className="text-[10px] text-muted-foreground">Daily average for July</p>
              </div>
              <div className="flex items-center gap-3">
                <span className="flex items-center gap-1 text-[10px] font-medium text-muted-foreground">
                  <span className="w-2 h-2 rounded-full bg-primary" />
                  Intake
                </span>
                <span className="flex items-center gap-1 text-[10px] font-medium text-muted-foreground">
                  <span className="w-2 h-2 rounded-full bg-accent" />
                  Bazar
                </span>
              </div>
            </div>

            <div className="h-32 relative">
              {/* Grid lines */}
              <div className="absolute inset-0 flex flex-col justify-between pointer-events-none">
                <div className="border-t border-border/15 w-full" />
                <div className="border-t border-border/15 w-full" />
                <div className="border-t border-border/15 w-full" />
              </div>

              {/* SVG chart */}
              <svg className="w-full h-full" viewBox="0 0 500 100" preserveAspectRatio="none">
                <defs>
                  <linearGradient id="heroGrad" x1="0" y1="0" x2="0" y2="1">
                    <stop offset="0%" stopColor="var(--primary)" stopOpacity="0.12" />
                    <stop offset="100%" stopColor="var(--primary)" stopOpacity="0" />
                  </linearGradient>
                </defs>
                <path
                  d="M0,80 Q50,40 100,50 T200,30 T300,75 T400,20 T500,45"
                  fill="none"
                  stroke="var(--accent)"
                  strokeWidth="2"
                  strokeLinecap="round"
                  opacity="0.7"
                />
                <path
                  d="M0,70 Q50,30 100,40 T200,20 T300,60 T400,10 T500,35"
                  fill="url(#heroGrad)"
                />
                <path
                  d="M0,70 Q50,30 100,40 T200,20 T300,60 T400,10 T500,35"
                  fill="none"
                  stroke="var(--primary)"
                  strokeWidth="2.5"
                  strokeLinecap="round"
                />
              </svg>
            </div>

            <div className="flex justify-between text-[9px] font-semibold text-muted-foreground/50 mt-2 select-none">
              <span>Jul 01</span>
              <span>Jul 08</span>
              <span>Jul 15</span>
              <span>Jul 22</span>
              <span>Jul 29</span>
            </div>
          </div>

          {/* Activity feed */}
          <div className="space-y-2">
            <p className="text-[10px] font-bold uppercase tracking-widest text-muted-foreground/60 mb-2">
              Recent Activity
            </p>
            {[
              { text: "Sadik added bazar list — ৳250", time: "2 min ago", dot: "bg-primary" },
              { text: "Manager approved Tanvir's deposit", time: "1 hour ago", dot: "bg-emerald-500" },
              { text: "Meal rate auto-calculated for July", time: "3 hours ago", dot: "bg-amber-500" },
            ].map((item, i) => (
              <div key={i} className="flex items-start gap-2.5 py-1.5">
                <span className={`w-1.5 h-1.5 rounded-full ${item.dot} mt-1.5 shrink-0`} />
                <div>
                  <p className="text-[11px] font-medium text-foreground/80 leading-snug">
                    {item.text}
                  </p>
                  <p className="text-[10px] text-muted-foreground/60">{item.time}</p>
                </div>
              </div>
            ))}
          </div>
        </div>
      </div>

      {/* Floating badge - deposit */}
      <div className="absolute -top-3 -right-3 sm:top-4 sm:right-4 hidden sm:block z-10">
        <div className="bg-card/90 backdrop-blur-sm px-3.5 py-2.5 rounded-lg border border-border/50 shadow-lg flex items-center gap-2.5">
          <div className="w-8 h-8 rounded-md bg-emerald-500/10 flex items-center justify-center">
            <span className="text-[13px] font-bold text-emerald-600 dark:text-emerald-400">৳</span>
          </div>
          <div>
            <p className="text-[9px] text-muted-foreground uppercase tracking-wider font-semibold leading-none mb-0.5">
              New Deposit
            </p>
            <p className="text-[13px] font-bold text-foreground">৳2,000.00</p>
          </div>
        </div>
      </div>

      {/* Floating badge - lock */}
      <div className="absolute -bottom-3 -left-3 sm:bottom-6 sm:left-4 hidden sm:block z-10">
        <div className="bg-card/90 backdrop-blur-sm px-3.5 py-2.5 rounded-lg border border-border/50 shadow-lg flex items-center gap-2.5">
          <div className="w-8 h-8 rounded-md bg-accent/10 flex items-center justify-center">
            <svg className="w-4 h-4 text-accent" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
              <rect x="3" y="11" width="18" height="11" rx="2" ry="2" />
              <path d="M7 11V7a5 5 0 0 1 10 0v4" />
            </svg>
          </div>
          <div>
            <p className="text-[9px] text-muted-foreground uppercase tracking-wider font-semibold leading-none mb-0.5">
              Auto Lock
            </p>
            <p className="text-[11px] font-bold text-foreground">Entry closed at 10 PM</p>
          </div>
        </div>
      </div>
    </div>
  );
}
