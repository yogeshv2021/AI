import os
import sys
import pandas as pd


def process_large_jmeter(input_file, output_file, chunk_size=100000):
    """Processes large JMeter CSV reports and appends a consolidated Total row."""
    if not os.path.exists(input_file):
        print(f"Error: Input file '{input_file}' not found.")
        sys.exit(1)

    print(f"Reading '{input_file}' in chunks of {chunk_size} rows...")
    chunk_summaries = []

    # Stream the file to keep RAM usage under 100MB
    for chunk in pd.read_csv(input_file, chunksize=chunk_size):
        chunk.columns = chunk.columns.str.strip()

        # Enforce exact datatypes for calculations
        chunk["success"] = chunk["success"].astype(str).str.lower() == "true"
        chunk["Latency"] = pd.to_numeric(chunk["Latency"], errors="coerce")

        # Group data immediately within the current chunk
        grouped = chunk.groupby("label")

        # Aggregate standard metrics for this chunk
        metrics = grouped.agg(
            Total_Count=("label", "count"),
            Success_Count=("success", "sum"),
            Min_Latency=("Latency", "min"),
            Max_Latency=("Latency", "max"),
            Sum_Latency=("Latency", "sum"),
        )

        chunk_summaries.append(metrics)

    print("Consolidating all chunks into global metrics...")
    full_df = pd.concat(chunk_summaries)
    final_grouped = full_df.groupby(full_df.index)

    # Global aggregation across all chunks
    final_metrics = final_grouped.agg(
        Total_Count=("Total_Count", "sum"),
        Success_Count=("Success_Count", "sum"),
        Min_Latency=("Min_Latency", "min"),
        Max_Latency=("Max_Latency", "max"),
        Sum_Latency=("Sum_Latency", "sum"),
    )

    # Compute derived metrics
    final_metrics["Failure_Count"] = (
        final_metrics["Total_Count"] - final_metrics["Success_Count"]
    )
    final_metrics["Avg_Latency"] = (
        final_metrics["Sum_Latency"] / final_metrics["Total_Count"]
    ).round(2)

    # Build primary table layout
    output_df = pd.DataFrame(
        {
            "label": final_metrics.index,
            "Total_Count": final_metrics["Total_Count"],
            "Success_Count": final_metrics["Success_Count"],
            "Failure_Count": final_metrics["Failure_Count"],
            "Min_Latency": final_metrics["Min_Latency"],
            "Max_Latency": final_metrics["Max_Latency"],
            "Avg_Latency": final_metrics["Avg_Latency"],
        }
    )

    # --- Generate Consolidation Row ---
    total_count = final_metrics["Total_Count"].sum()
    success_count = final_metrics["Success_Count"].sum()
    failure_count = final_metrics["Failure_Count"].sum()
    global_min = final_metrics["Min_Latency"].min()
    global_max = final_metrics["Max_Latency"].max()

    # Fixed syntax line below
    global_avg = (
        round(final_metrics["Sum_Latency"].sum() / total_count, 2)
        if total_count > 0
        else 0
    )

    total_row = pd.DataFrame(
        [
            {
                "label": "TOTAL_CONSOLIDATED",
                "Total_Count": total_count,
                "Success_Count": success_count,
                "Failure_Count": failure_count,
                "Min_Latency": global_min,
                "Max_Latency": global_max,
                "Avg_Latency": global_avg,
            }
        ]
    )

    # Append consolidation row to final dataframe
    output_df = pd.concat([output_df, total_row], ignore_index=True)

    # Export to structured CSV file with headers
    output_df.to_csv(output_file, index=False)
    print(f"Success! Analysis with consolidation saved to: {output_file}")


if __name__ == "__main__":
    if len(sys.argv) < 3:
        print("Error: Missing file arguments.")
        print("Usage: python analyze.py <input_jmeter_csv> <output_summary_csv>")
        sys.exit(1)

    input_csv_path = sys.argv[1]
    output_csv_path = sys.argv[2]

    process_large_jmeter(input_csv_path, output_csv_path)
