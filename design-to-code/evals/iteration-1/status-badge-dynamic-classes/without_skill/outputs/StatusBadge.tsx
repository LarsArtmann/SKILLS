type Status = "success" | "warning" | "error" | "info";

const STATUS_STYLES: Record<Status, string> = {
  success: "bg-green-100 text-green-800 ring-green-600/20",
  warning: "bg-amber-100 text-amber-800 ring-amber-600/20",
  error: "bg-red-100 text-red-800 ring-red-600/20",
  info: "bg-blue-100 text-blue-800 ring-blue-600/20",
};

export function StatusBadge({ status }: { status: Status }) {
  return (
    <span
      className={`inline-flex items-center rounded-full px-2.5 py-0.5 text-xs font-medium capitalize ring-1 ring-inset ${STATUS_STYLES[status]}`}
    >
      {status}
    </span>
  );
}

export default StatusBadge;
