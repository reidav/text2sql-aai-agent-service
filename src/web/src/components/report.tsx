import Block from "./block";
import { useRemark } from "react-remark";
import remarkGemoji from "remark-gemoji";
import { useAppSelector } from "../store/hooks";
import { useEffect } from "react";
import "./report.css";

export const Report = () => {
  // const [reactContent, setMarkdownSource] = useRemark({
  //   //@ts-expect-error - this is a bug in the types
  //   remarkPlugins: [remarkGemoji],
  //   remarkToRehypeOptions: { allowDangerousHtml: true },
  //   rehypeReactOptions: {},
  // });

  const reports = useAppSelector((state) => state.report);
  const currentReport = reports.currentReport;

  // useEffect(() => {
  //   // setMarkdownSource(reports.currentReport);
  // }, [reports.currentReport, setMarkdownSource]);
      /* <Block innerClassName="text-left" outerClassName="mt-10 mb-40">
        {reactContent}
      </Block> */

  return (
    <>
      {currentReport ? (
        <div>
          <div className="text-3sl text-gray-800 mb-4">{currentReport.message}</div>
          
          <div className="text-3sl text-gray-800 mb-4">{currentReport.query}</div>

          {currentReport.files_url?.map((file, index) => (
            <img key={index} src={file}></img>
          ))}
        </div>
      ) : null}
    </>
  );
};

export default Report;
