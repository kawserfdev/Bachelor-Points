import { Navbar } from "@/components/layout/Navbar";
import { Footer } from "@/components/layout/Footer";
import Link from "next/link";
import { ArrowLeft, Shield } from "lucide-react";

export const metadata = {
  title: "Privacy Policy & Terms — BachelorPoints",
  description: "Privacy Policy and Terms of Service for BachelorPoints Mess Management Platform.",
};

export default function PrivacyPage() {
  return (
    <div className="flex flex-col min-h-screen bg-background text-foreground antialiased selection:bg-primary/30">
      <Navbar />
      <main className="flex-grow pt-32 pb-20">
        <div className="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8">
          <Link
            href="/"
            className="inline-flex items-center gap-2 text-xs font-semibold text-muted-foreground hover:text-foreground mb-8 transition-colors"
          >
            <ArrowLeft className="w-4 h-4" />
            <span>Back to Home</span>
          </Link>

          <div className="p-8 sm:p-12 rounded-3xl bg-card border border-border/70 shadow-sm space-y-8">
            <div className="flex items-center gap-3 pb-6 border-b border-border/50">
              <div className="w-12 h-12 rounded-xl bg-[#8B3DFF]/15 text-[#8B3DFF] flex items-center justify-center">
                <Shield className="w-6 h-6" />
              </div>
              <div>
                <h1 className="text-2xl sm:text-3xl font-extrabold text-foreground">
                  Privacy Policy & Data Security
                </h1>
                <p className="text-xs text-muted-foreground mt-1">
                  Last Updated: August 2026 • BachelorPoints Bangladesh
                </p>
              </div>
            </div>

            <div className="space-y-6 text-sm text-muted-foreground leading-relaxed">
              <section className="space-y-2">
                <h2 className="text-base font-bold text-foreground">
                  1. Information We Collect
                </h2>
                <p>
                  BachelorPoints collects user-provided information strictly necessary for mess operations, including your name, email address, mess membership group code, meal portion counts, and shared bazar expense entries.
                </p>
              </section>

              <section className="space-y-2">
                <h2 className="text-base font-bold text-foreground">
                  2. How Your Mess Data is Protected
                </h2>
                <p>
                  All mess account data is private and isolated. Only members who have entered your specific mess group invite code and have been approved by the mess manager can view the group&apos;s meal ledger, expense receipts, and balance calculations.
                </p>
              </section>

              <section className="space-y-2">
                <h2 className="text-base font-bold text-foreground">
                  3. Zero Third-Party Selling
                </h2>
                <p>
                  We do not sell, rent, or trade personal data or financial logs to advertising networks or third-party brokers.
                </p>
              </section>

              <section className="space-y-2">
                <h2 className="text-base font-bold text-foreground">
                  4. Contact & Inquiries
                </h2>
                <p>
                  For questions regarding data privacy or to request account deletion, please email our team at{" "}
                  <a href="mailto:support@bachelorpoints.com" className="text-[#8B3DFF] font-semibold underline">
                    support@bachelorpoints.com
                  </a>.
                </p>
              </section>
            </div>
          </div>
        </div>
      </main>
      <Footer />
    </div>
  );
}
