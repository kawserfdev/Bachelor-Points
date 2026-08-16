import { Navbar } from "@/components/layout/Navbar";
import { Hero } from "@/components/sections/Hero";
import { ProblemSolution } from "@/components/sections/ProblemSolution";
import { Features } from "@/components/sections/Features";
import { AppScreenshots } from "@/components/sections/AppScreenshots";
import { SmartBazar } from "@/components/sections/SmartBazar";
import { ManagerControl } from "@/components/sections/ManagerControl";
import { MonthlyAnalytics } from "@/components/sections/MonthlyAnalytics";
import { HowItWorks } from "@/components/sections/HowItWorks";
import { DownloadApp } from "@/components/sections/DownloadApp";
import { TrustBenefits } from "@/components/sections/TrustBenefits";
import { Testimonials } from "@/components/sections/Testimonials";
import { FAQ } from "@/components/sections/FAQ";
import { CTA } from "@/components/sections/CTA";
import { Footer } from "@/components/layout/Footer";

export default function Home() {
  return (
    <div className="flex flex-col min-h-screen bg-background text-foreground antialiased selection:bg-primary/30">
      <Navbar />
      <main className="flex-grow">
        <Hero />
        <ProblemSolution />
        <Features />
        <AppScreenshots />
        <SmartBazar />
        <ManagerControl />
        <MonthlyAnalytics />
        <HowItWorks />
        <DownloadApp />
        <TrustBenefits />
        <Testimonials />
        <FAQ />
        <CTA />
      </main>
      <Footer />
    </div>
  );
}
