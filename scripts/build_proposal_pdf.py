from pathlib import Path

import hashlib


_original_md5 = hashlib.md5


def _md5_compat(*args, **kwargs):
    kwargs.pop("usedforsecurity", None)
    return _original_md5(*args, **kwargs)


hashlib.md5 = _md5_compat

from reportlab.lib import colors
from reportlab.lib.pagesizes import A4
from reportlab.lib.styles import ParagraphStyle
from reportlab.lib.units import mm
from reportlab.pdfbase import pdfmetrics
from reportlab.pdfbase.ttfonts import TTFont
from reportlab.platypus import Paragraph, SimpleDocTemplate, Spacer, Table, TableStyle
from pypdf import PdfReader


ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / "docs" / "competition" / "MoonSpectrum-proposal.pdf"
FONT = Path("C:/Windows/Fonts/msyh.ttc")
BOLD_FONT = Path("C:/Windows/Fonts/msyhbd.ttc")


def para(text, style):
    return Paragraph(text, style)


def main():
    pdfmetrics.registerFont(TTFont("MSYH", str(FONT)))
    pdfmetrics.registerFont(TTFont("MSYH-Bold", str(BOLD_FONT)))

    red = colors.HexColor("#b91c1c")
    dark_red = colors.HexColor("#7f1d1d")
    light_red = colors.HexColor("#fee2e2")
    pale_red = colors.HexColor("#fff7f7")
    ink = colors.HexColor("#1f2937")

    styles = {
        "title": ParagraphStyle(
            "title",
            fontName="MSYH-Bold",
            fontSize=18,
            leading=22,
            textColor=dark_red,
            spaceAfter=5,
            alignment=1,
        ),
        "body": ParagraphStyle(
            "body",
            fontName="MSYH",
            fontSize=9.1,
            leading=12.2,
            textColor=ink,
        ),
        "section": ParagraphStyle(
            "section",
            fontName="MSYH-Bold",
            fontSize=10.2,
            leading=12.5,
            textColor=red,
            spaceBefore=3.5,
            spaceAfter=1.5,
        ),
        "small": ParagraphStyle(
            "small",
            fontName="MSYH",
            fontSize=8.0,
            leading=10.2,
            textColor=colors.HexColor("#4b5563"),
        ),
    }

    doc = SimpleDocTemplate(
        str(OUT),
        pagesize=A4,
        leftMargin=13 * mm,
        rightMargin=13 * mm,
        topMargin=12 * mm,
        bottomMargin=10 * mm,
    )

    header_bar = Table([[""]], colWidths=[doc.width], rowHeights=[3.2 * mm])
    header_bar.setStyle(
        TableStyle(
            [
                ("BACKGROUND", (0, 0), (-1, -1), red),
                ("LINEBELOW", (0, 0), (-1, -1), 1.0, dark_red),
            ]
        )
    )

    story = [
        header_bar,
        Spacer(1, 3),
        para("MoonSpectrum 项目申报书", styles["title"]),
        para("项目方向：科学信号处理基础库 | 参赛类型：原创 MoonBit 生态项目 | 许可证：Apache-2.0", styles["small"]),
        Spacer(1, 4),
    ]

    summary = [
        [para("项目名称", styles["body"]), para("MoonSpectrum", styles["body"])],
        [para("GitHub 仓库", styles["body"]), para("https://github.com/chgttyyr/MoonSpectrum", styles["body"])],
        [para("GitLink 仓库", styles["body"]), para("https://gitlink.org.cn/chgttyyr/MoonSpectrum", styles["body"])],
        [
            para("Mooncakes 状态", styles["body"]),
            para("已检索 fft/fourier/spectrum/wavelet/convolution/iir，未发现直接重合包；后续发布 chgttyyr/MoonSpectrum", styles["body"]),
        ],
    ]
    table = Table(summary, colWidths=[30 * mm, 137 * mm])
    table.setStyle(
        TableStyle(
            [
                ("FONTNAME", (0, 0), (-1, -1), "MSYH"),
                ("FONTNAME", (0, 0), (0, -1), "MSYH-Bold"),
                ("FONTSIZE", (0, 0), (-1, -1), 8.5),
                ("LEADING", (0, 0), (-1, -1), 10.5),
                ("TEXTCOLOR", (0, 0), (0, -1), dark_red),
                ("GRID", (0, 0), (-1, -1), 0.35, colors.HexColor("#fca5a5")),
                ("BACKGROUND", (0, 0), (0, -1), light_red),
                ("BACKGROUND", (1, 0), (1, -1), pale_red),
                ("VALIGN", (0, 0), (-1, -1), "TOP"),
                ("LEFTPADDING", (0, 0), (-1, -1), 5),
                ("RIGHTPADDING", (0, 0), (-1, -1), 5),
                ("TOPPADDING", (0, 0), (-1, -1), 3.2),
                ("BOTTOMPADDING", (0, 0), (-1, -1), 3.2),
            ]
        )
    )
    story.extend([table, Spacer(1, 4)])

    sections = [
        (
            "项目简介",
            "MoonSpectrum 是一个面向 MoonBit 生态的科学信号处理基础库，提供复数运算、DFT/FFT、频谱分析、窗函数、卷积、基础 FIR 滤波和命令行分析工具。项目服务于传感器数据、实验数据、振动信号、周期信号、教学示例和边缘计算前处理。与音频 DSP/音频引擎不同，本项目不绑定播放、采集或具体设备后端，而是沉淀可复用、可验证、可扩展的通用算法层。",
        ),
        (
            "为什么值得做",
            "MoonBit 生态已有 Web、图形、Markdown、数据库和音频相关项目，但通用科学信号处理方向仍缺少小而稳的基础包。FFT、窗函数、卷积和频谱分析是工程、物理实验、嵌入式传感器、振动诊断和教学场景中的共性能力，适合作为 MoonBit 跨学科应用生态的基础设施。",
        ),
        (
            "拟实现的核心功能",
            "1. 复数类型与近似比较；2. DFT、radix-2 FFT、inverse FFT；3. 幅度谱、功率谱、频率 bin、主频检测；4. 正弦波、方波、脉冲、chirp、确定性白噪声；5. Rectangular、Hann、Hamming、Blackman 窗函数；6. 线性卷积、循环卷积、移动平均、FIR 低通/高通 taps；7. CLI 支持 demo、fft、analyze、window、convolve，并用 CSV fixtures 做可复现示例。",
        ),
        (
            "实现计划与验收方式",
            "项目采用根包导出稳定 API，cmd/main 作为 CLI 入口。仓库包含 README、LICENSE、CHANGELOG、CI、示例数据、接口文件、验收脚本、Mooncakes 检索记录和一页 PDF。验收命令覆盖 moon info、moon fmt --check、moon check --warn-list +73、moon test、CLI smoke test，以及 scripts/verify_acceptance.ps1。",
        ),
        (
            "边界与扩展",
            "本期不做完整音频引擎、不做大型矩阵计算、不依赖 native FFI，优先保证算法清晰、测试充分、跨后端可运行。当前已实现 STFT/谱图、IIR 滤波、Welch PSD、重采样、统计质量指标和事件检测；后续扩展方向包括流式 CSV/JSON 数据管线、时间戳支持和 WebAssembly 可视化 Demo。",
        ),
    ]

    for title, body in sections:
        story.append(para(title, styles["section"]))
        story.append(para(body, styles["body"]))

    story.append(Spacer(1, 4))
    story.append(para("交付物与审核要点", styles["section"]))
    checklist = [
        [
            para("工程交付", styles["body"]),
            para("根包 API、cmd/main CLI、examples 数据、README、API/设计文档、Apache-2.0 许可证、CHANGELOG。", styles["body"]),
        ],
        [
            para("质量验证", styles["body"]),
            para("63 个 MoonBit 测试覆盖 FFT/IFFT、卷积、窗函数、滤波、统计、频谱、事件检测、校准、谱图和边界条件；CLI smoke 覆盖基础与扩展分析命令。", styles["body"]),
        ],
        [
            para("参赛材料", styles["body"]),
            para("一页红色风格申报书、验收清单、Mooncakes 检索记录、GitHub/GitLink 公开仓库和 10-20 个真实提交。", styles["body"]),
        ],
    ]
    checklist_table = Table(checklist, colWidths=[27 * mm, 140 * mm])
    checklist_table.setStyle(
        TableStyle(
            [
                ("FONTNAME", (0, 0), (-1, -1), "MSYH"),
                ("FONTNAME", (0, 0), (0, -1), "MSYH-Bold"),
                ("FONTSIZE", (0, 0), (-1, -1), 8.4),
                ("LEADING", (0, 0), (-1, -1), 10.5),
                ("TEXTCOLOR", (0, 0), (0, -1), dark_red),
                ("GRID", (0, 0), (-1, -1), 0.32, colors.HexColor("#fca5a5")),
                ("BACKGROUND", (0, 0), (0, -1), light_red),
                ("BACKGROUND", (1, 0), (1, -1), pale_red),
                ("VALIGN", (0, 0), (-1, -1), "TOP"),
                ("LEFTPADDING", (0, 0), (-1, -1), 5),
                ("RIGHTPADDING", (0, 0), (-1, -1), 5),
                ("TOPPADDING", (0, 0), (-1, -1), 3.2),
                ("BOTTOMPADDING", (0, 0), (-1, -1), 3.2),
            ]
        )
    )
    story.append(checklist_table)
    story.append(Spacer(1, 3))
    roadmap = [
        [
            para("本期", styles["body"]),
            para("完成通用算法层、命令行工具、示例数据和测试闭环，保证跨后端可运行、可复查、可发布。", styles["body"]),
        ],
        [
            para("中期", styles["body"]),
            para("补充流式 CSV/JSON 数据处理、时间戳语义和 WebAssembly 可视化 Demo。", styles["body"]),
        ],
        [
            para("后续", styles["body"]),
            para("围绕传感器分析、实验教学和 WebAssembly 可视化 Demo 形成 MoonBit 科学计算应用样例。", styles["body"]),
        ],
    ]
    roadmap_table = Table(roadmap, colWidths=[27 * mm, 140 * mm])
    roadmap_table.setStyle(
        TableStyle(
            [
                ("FONTNAME", (0, 0), (-1, -1), "MSYH"),
                ("FONTNAME", (0, 0), (0, -1), "MSYH-Bold"),
                ("FONTSIZE", (0, 0), (-1, -1), 8.2),
                ("LEADING", (0, 0), (-1, -1), 10.2),
                ("TEXTCOLOR", (0, 0), (0, -1), dark_red),
                ("GRID", (0, 0), (-1, -1), 0.32, colors.HexColor("#fca5a5")),
                ("BACKGROUND", (0, 0), (0, -1), light_red),
                ("BACKGROUND", (1, 0), (1, -1), colors.white),
                ("VALIGN", (0, 0), (-1, -1), "TOP"),
                ("LEFTPADDING", (0, 0), (-1, -1), 5),
                ("RIGHTPADDING", (0, 0), (-1, -1), 5),
                ("TOPPADDING", (0, 0), (-1, -1), 3),
                ("BOTTOMPADDING", (0, 0), (-1, -1), 3),
            ]
        )
    )
    story.append(roadmap_table)
    story.append(Spacer(1, 3))
    footer = Table(
        [[para("提交口径：原创项目；公开仓库；10-20 个真实有效 commits；GitHub 与 GitLink 同步；公开贡献者限定为账号创建者本人。", styles["small"])]],
        colWidths=[doc.width],
    )
    footer.setStyle(
        TableStyle(
            [
                ("BACKGROUND", (0, 0), (-1, -1), light_red),
                ("BOX", (0, 0), (-1, -1), 0.35, red),
                ("LEFTPADDING", (0, 0), (-1, -1), 5),
                ("RIGHTPADDING", (0, 0), (-1, -1), 5),
                ("TOPPADDING", (0, 0), (-1, -1), 3),
                ("BOTTOMPADDING", (0, 0), (-1, -1), 3),
            ]
        )
    )
    story.append(footer)

    doc.build(story)
    pages = len(PdfReader(str(OUT)).pages)
    if pages != 1:
        raise SystemExit(f"proposal must be one page, got {pages}")
    print(OUT)


if __name__ == "__main__":
    main()
