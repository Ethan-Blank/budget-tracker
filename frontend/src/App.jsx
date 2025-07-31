import { useState, useEffect } from "react";
import api from "./api/api";
import TransactionForm from "./components/TransactionForm";
import TransactionList from "./components/TransactionList";

function App() {
  const [transactions, setTransactions] = useState([]);

  // Fetch transactions on page load
  useEffect(() => {
    const fetchTransactions = async () => {
      try {
        const res = await api.get("/transactions");
        setTransactions(res.data);
      } catch (err) {
        console.error("Failed to fetch transactions:", err);
      }
    };
    fetchTransactions();
  }, []);

  return (
    <div>
      <h1>Budget Tracker</h1>
      <TransactionForm onAdd={(tx) => setTransactions((prev) => [...prev, tx])} />
      <TransactionList transactions={transactions} />
    </div>
  );
}

export default App;
