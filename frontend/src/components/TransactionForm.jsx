import { useState } from "react";
import api from "../api/api";

export default function TransactionForm({ onAdd }) {
  const [amount, setAmount] = useState("");
  const [category, setCategory] = useState("");

  const handleSubmit = async (e) => {
    e.preventDefault();
    try {
      const res = await api.post("/transaction", {
        amount: parseFloat(amount),
        category,
      });
      onAdd(res.data.transaction);
      setAmount("");
      setCategory("");
    } catch (err) {
      console.error("Failed to add transaction:", err);
    }
  };

  return (
    <form onSubmit={handleSubmit}>
      <input
        type="number"
        value={amount}
        onChange={(e) => setAmount(e.target.value)}
        placeholder="Amount"
        required
      />
      <input
        value={category}
        onChange={(e) => setCategory(e.target.value)}
        placeholder="Category"
        required
      />
      <button type="submit">Add Transaction</button>
    </form>
  );
}

