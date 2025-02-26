import { githubDevSubsPort } from "../utils/ghutils";
export interface IMessage {
  type: "message" | "database researcher" | "sql writer" | "sql executor" | "dataviz" | "error" | "partial";
  message: string;
  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  data?: any;
}

export interface IReport {
  query: string;
  message: string;
  files_url: string[];
}

export interface IReportCollection {
  current: number;
  reports: IReport[];
  currentReport: IReport | undefined;
}

export interface IChatTurn {
  name: string;
  avatar: string;
  image: string | null;
  message: string;
  status: "waiting" | "done";
  type: "user" | "assistant";
}

export const startReportingTask = (
  question: string,
  addMessage: { (message: IMessage): void },
  addReport: { (report: IReport): void }
  // addToReport: { (text: string): void }
) => {
  // internal function to read chunks from a stream
  function readChunks(reader: ReadableStreamDefaultReader<Uint8Array>) {
    return {
      async *[Symbol.asyncIterator]() {
        let readResult = await reader.read();
        while (!readResult.done) {
          yield readResult.value;
          readResult = await reader.read();
        }
      },
    };
  }

  const configuration = {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      "Connection": "keep-alive",
    },
    body: JSON.stringify({
      question: question,
    }),
  };

  const hostname = window.location.hostname;
  const apiPort = 8000;
  
  const endpoint =
    (hostname === 'localhost' || hostname === '127.0.0.1')
      ? `http://localhost:${apiPort}`
      : hostname.endsWith('github.dev')
      ? `${githubDevSubsPort(hostname, apiPort)}/`
      : "";


  const url = `${
    endpoint.endsWith("/") ? endpoint : endpoint + "/"
  }api/report`;

  const image_url = `${
    endpoint.endsWith("/") ? endpoint : endpoint + "/"
  }api/images`;

  const callApi = async () => {
    try {
      const response = await fetch(url, configuration);
      const reader = response.body?.getReader();
      if (!reader) return;

      const chunks = readChunks(reader);
      for await (const chunk of chunks) {
        const text = new TextDecoder().decode(chunk);
        const parts = text.split("\n");
        for (let part of parts) {
          part = part.trim();
          if (!part || part.length === 0) continue;
          // console.log(part);
          const message = JSON.parse(part) as IMessage;
          addMessage(message);

          if (message.type === "dataviz") {
            console.log("DataViz message", message);
            if (message.data && message.data.message) {
              addReport({
                query: message.data.query,
                message: message.data.message,
                files_url: message.data.images.map((image: string) => image_url + "/" + image),
              });
            }
          }
        }
      }
    } catch (e) {
      console.log(e);
    }
  };

  callApi();

};