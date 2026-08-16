"use client";

import Link from "next/link";

export function Footer() {
  return (
    <footer className="border-t border-border/60 bg-secondary/30 pt-16 pb-12">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div className="grid grid-cols-2 md:grid-cols-4 lg:grid-cols-5 gap-8 lg:gap-12 mb-14">
          {/* Brand Col */}
          <div className="col-span-2 md:col-span-4 lg:col-span-2 space-y-4">
            <Link href="/" className="flex items-center gap-3 group">
              <div className="w-8 h-8 rounded-xl bg-gradient-to-tr from-[#8B3DFF] to-[#A855F7] p-0.5 flex items-center justify-center shadow-[0_0_15px_rgba(139,61,255,0.3)]">
                <div className="w-full h-full bg-[#0A0A0F] rounded-[9px] flex items-center justify-center">
                  <svg className="w-4 h-4" viewBox="0 0 24 24" fill="none">
                    <path
                      d="M12 2L2 7L12 12L22 7L12 2Z"
                      stroke="#C084FC"
                      strokeWidth="2"
                      strokeLinecap="round"
                      strokeLinejoin="round"
                    />
                    <path
                      d="M2 17L12 22L22 17"
                      stroke="#8B3DFF"
                      strokeWidth="2"
                      strokeLinecap="round"
                      strokeLinejoin="round"
                    />
                  </svg>
                </div>
              </div>
              <span className="text-base font-extrabold tracking-tight text-foreground">
                Bachelor<span className="text-[#A855F7]">Points</span>
              </span>
            </Link>

            <p className="text-xs sm:text-sm text-muted-foreground leading-relaxed max-w-sm font-normal">
              Digital Mess & Meal Management Platform for bachelors, university students,
              and hostel communities across Bangladesh. Making mess life simpler, one meal at a time.
            </p>

            <div className="pt-1">
              <span className="inline-flex items-center gap-1.5 text-xs font-semibold text-emerald-500 bg-emerald-500/10 px-3 py-1 rounded-full">
                <span>🇧🇩</span> Made with ❤️ in Bangladesh
              </span>
            </div>
          </div>

          {/* Product Links */}
          <div className="space-y-3">
            <h4 className="text-xs font-bold uppercase tracking-widest text-foreground">
              Product
            </h4>
            <ul className="space-y-2 text-xs sm:text-sm text-muted-foreground">
              <li>
                <Link href="#features" className="hover:text-foreground transition-colors">
                  Meal Management
                </Link>
              </li>
              <li>
                <Link href="#features" className="hover:text-foreground transition-colors">
                  Expense & Bazar
                </Link>
              </li>
              <li>
                <Link href="#smart-bazar" className="hover:text-foreground transition-colors">
                  Duty Rotation
                </Link>
              </li>
              <li>
                <Link href="#features" className="hover:text-foreground transition-colors">
                  PDF Monthly Reports
                </Link>
              </li>
              <li>
                <Link href="/app/login" className="hover:text-foreground transition-colors">
                  Web & Mobile App
                </Link>
              </li>
            </ul>
          </div>

          {/* Resources Links */}
          <div className="space-y-3">
            <h4 className="text-xs font-bold uppercase tracking-widest text-foreground">
              Resources
            </h4>
            <ul className="space-y-2 text-xs sm:text-sm text-muted-foreground">
              <li>
                <Link href="#how-it-works" className="hover:text-foreground transition-colors">
                  How It Works
                </Link>
              </li>
              <li>
                <Link href="#faq" className="hover:text-foreground transition-colors">
                  FAQ
                </Link>
              </li>
              <li>
                <Link href="#product-demo" className="hover:text-foreground transition-colors">
                  Interactive Demo
                </Link>
              </li>
              <li>
                <Link href="/privacy" className="hover:text-foreground transition-colors">
                  Privacy Policy
                </Link>
              </li>
            </ul>
          </div>

          {/* Company Links */}
          <div className="space-y-3">
            <h4 className="text-xs font-bold uppercase tracking-widest text-foreground">
              Company
            </h4>
            <ul className="space-y-2 text-xs sm:text-sm text-muted-foreground">
              <li>
                <Link href="/" className="hover:text-foreground transition-colors">
                  About BachelorPoints
                </Link>
              </li>
              <li>
                <a href="mailto:bachelorpointsofficial@gmail.com" className="hover:text-foreground transition-colors">
                  Contact Support
                </a>
              </li>
              <li>
                <Link href="/privacy" className="hover:text-foreground transition-colors">
                  Terms of Service
                </Link>
              </li>
            </ul>
          </div>
        </div>

        {/* Bottom copyright & social links */}
        <div className="pt-8 border-t border-border/50 flex flex-col sm:flex-row items-center justify-between gap-4 text-xs text-muted-foreground">
          <p>
            &copy; {new Date().getFullYear()} BachelorPoints. All rights reserved.
          </p>

          <div className="flex items-center gap-4">
            <Link href="/privacy" className="hover:text-foreground transition-colors">
              Privacy
            </Link>
            <span>•</span>
            <Link href="/privacy" className="hover:text-foreground transition-colors">
              Security
            </Link>
            <span>•</span>
            <a href="mailto:bachelorpointsofficial@gmail.com" className="hover:text-foreground transition-colors">
              bachelorpointsofficial@gmail.com
            </a>
          </div>
        </div>
      </div>
    </footer>
  );
}
