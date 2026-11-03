export type BadgeStatus = "success" | "warning" | "error" | "info";

const STATUS_STYLES: Record<BadgeStatus, string> = {
  success: "bg-green-100 text-green-800",
  warning: "bg-amber-100 text-amber-800",
  error: "bg-red-100 text-red-800",
  info: "bg-blue-100 text-blue-800",
};

const BASE_CLASSES =
  "inline-flex items-center rounded-full px-2.5 py-0.5 text-xs font-medium capitalize";

export function StatusBadge({ status }: { status: BadgeStatus }) {
  return (
    <span className={`${BASE_CLASSES} ${STATUS_STYLES[status]}`}>{status}</span>
  );
}
