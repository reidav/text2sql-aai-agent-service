import {
  PaperAirplaneIcon,
  ClipboardDocumentIcon,
  ArrowPathIcon,
} from "@heroicons/react/24/outline";
import { useState } from "react";
import { IMessage, IReport, startReportingTask } from "../store";
import { useAppDispatch } from "../store/hooks";
import { addMessage } from "../store/messageSlice";
import { addReport } from "../store/reportSlice";

export const Task = () => {
  const [question, setQuestion] = useState("");

  const dispatch = useAppDispatch();

  const setExample = () => {
    setQuestion(
      "Show me the latest market data from Apple. It should be a line chart."
    );
  };


  const reset = () => {
    setQuestion("");
  };

  const newMessage = (message: IMessage) => {
    dispatch(addMessage(message));
  };

  const newReport = (report: IReport) => {
    dispatch(addReport(report));
  };

  // const addToReport = (text: string) => {
  //   dispatch(addToCurrentReport(text));
  // };

  const startWork = () => {
    if (question === "") {
      return;
    }
    startReportingTask(
      question,
      newMessage,
      newReport
    );
  }

  return (
    <div className="p-3">
      <div className="text-start">
        <label
          htmlFor="research"
          className="block text-sm font-medium leading-6 text-gray-900"
        >
          Report
        </label>
        <p className="mt-1 text-sm leading-6 text-gray-400">
          What kinds of report should I build ?
        </p>
        <div className="mt-2">
          <div className=" flex rounded-md shadow-sm ring-1 ring-inset ring-gray-300 focus-within:ring-2 focus-within:ring-inset focus-within:ring-blue-600">
            <textarea
              id="question"
              name="question"
              rows={3}
              cols={60}
              className="p-2 block w-full rounded-md border-0 py-1.5 text-gray-900 shadow-sm ring-1 ring-inset ring-gray-300 placeholder:text-gray-400 focus:ring-2 focus:ring-inset focus:ring-indigo-600 sm:text-sm sm:leading-6"
              value={question}
              onChange={(e) => setQuestion(e.target.value)}
            />
          </div>
        </div>
      </div>
      <div className="flex justify-end gap-2 mt-10">
        <button
          type="button"
          className="flex flex-row gap-3 items-center rounded-md bg-white px-3.5 py-2.5 text-sm font-semibold text-gray-900 shadow-sm ring-1 ring-inset ring-gray-300 hover:bg-gray-50"
          onClick={reset}
        >
          <ArrowPathIcon className="w-6" />
          <span>Reset</span>
        </button>
        <button
          type="button"
          className="flex flex-row gap-3 items-center rounded-md bg-white px-3.5 py-2.5 text-sm font-semibold text-gray-900 shadow-sm ring-1 ring-inset ring-gray-300 hover:bg-gray-50"
          onClick={setExample}
        >
          <ClipboardDocumentIcon className="w-6" />
          <span>Example</span>
        </button>
        <button
          type="button"
          className="flex flex-row gap-3 items-center rounded-md bg-indigo-100 px-3.5 py-2.5 text-sm font-semibold text-gray-900 shadow-sm ring-1 ring-inset ring-gray-300 hover:bg-gray-50"
          onClick={startWork}
        >
          <PaperAirplaneIcon className="w-6" />
          <span>Start Work</span>
        </button>
      </div>
    </div>
  );
};

export default Task;
